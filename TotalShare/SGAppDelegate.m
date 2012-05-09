//
//  SGAppDelegate.m
//  TotalShare
//
//  Created by Simon Grätzer on 20.03.12.
//  Copyright (c) 2012 Simon Grätzer. All rights reserved.
//

#import "SGAppDelegate.h"
#import "SGManager.h"
#import "HTTPServer.h"
#import "SGDirWatchdog.h"
#import "NSArray+Globbing_h.h"
#import "NSURL+Cloud.h"

#include <ifaddrs.h>
#include <arpa/inet.h>


SGAppDelegate *appDelegate = nil;

@implementation SGAppDelegate

@synthesize documentURLs = _documentURLs;
@synthesize query = _query;
@synthesize window = _window;
@synthesize queue = _queue;


#pragma mark - Document URLs
- (NSURL *)localDocumentsURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)ubiquitousDocumentsURL
{
    return [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"];
}

- (void)setDocumentURLs:(NSMutableArray *)documentURLs {
    [_documentURLs release];
    _documentURLs = [documentURLs retain];

    UITableViewController *tableViewC = [self.window.rootViewController.childViewControllers objectAtIndex:0];
    [tableViewC.tableView reloadData];
}

- (NSMutableArray *)documentURLs
{
    if (!_documentURLs) {
        _documentURLs = [[NSMutableArray alloc] init];
        
        // Documents online
        for (NSMetadataItem *item in self.query.results) {
            NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
            [_documentURLs addObject:url];
        }
        
        //Documents offline
        for (NSString *suffix in [SGManager supportedFiles]) {
            NSArray *filtered = [NSArray arrayWithURLsMatchingPattern:
                                 [NSString stringWithFormat:@"*.%@", suffix]
                                                          inDirectory:[self localDocumentsURL].path];
            [_documentURLs addObjectsFromArray:filtered];
        }
        
        [_documentURLs sortUsingComparator:^NSComparisonResult(NSURL *url1, NSURL *url2) {
            return [[url1 lastPathComponent] localizedStandardCompare:[url2 lastPathComponent]];
        }];
        
    }
    return _documentURLs;
}

#pragma mark - Queue
- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [NSOperationQueue new];
    }
    return _queue;
}

#pragma mark - iCloud
- (BOOL)updateURL:(NSURL *) url setUbiquitous:(BOOL)ubitiqous; {
    if (url.isCloud ^ ubitiqous) {
        NSURL *baseURL = (ubitiqous ? [self ubiquitousDocumentsURL] : [self localDocumentsURL]);
        NSURL *destinationURL = [baseURL URLByAppendingPathComponent:[url lastPathComponent]];
        BOOL success = [[NSFileManager defaultManager] setUbiquitous:ubitiqous itemAtURL:url destinationURL:destinationURL error:NULL];
        self.documentURLs = nil;
        return success;
    }
    return NO;
}

- (void)deleteURL:(NSURL *)url; {
    [self.queue addOperationWithBlock:^{
        NSFileCoordinator *coordinator = [[[NSFileCoordinator alloc] initWithFilePresenter:nil] autorelease];
        [coordinator coordinateWritingItemAtURL:url options:NSFileCoordinatorWritingForDeleting error:NULL byAccessor:^(NSURL *newURL) {
            [SGManager deleteMetadata:url];
            [[NSFileManager defaultManager] removeItemAtURL:newURL error:NULL];
        }];
    }];
}

- (void)updateUbiquitousDocuments:(NSNotification *)notification
{
    self.documentURLs = nil;
}

- (NSMetadataQuery *)query {
    if (!_query) {
        NSURL *ubiquitousDocumentsURL = [self ubiquitousDocumentsURL];
        if (ubiquitousDocumentsURL) {
            NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
            query.predicate = [NSPredicate predicateWithFormat:@"%K like '*'", NSMetadataItemFSNameKey];
            query.searchScopes = [NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUbiquitousDocuments:) name:NSMetadataQueryDidFinishGatheringNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUbiquitousDocuments:) name:NSMetadataQueryDidUpdateNotification object:nil];
            [query startQuery];
            [query enableUpdates];
            _query = query;
        }
    }
    return _query;
}

- (NSString *)getIPAddress { 
    NSString *address = @"localhost"; 
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL; 
    int success = 0; 
    
    // retrieve the current interfaces - returns 0 on success 
    success = getifaddrs(&interfaces);
    if (success == 0) { 
        // Loop through linked list of interfaces 
        temp_addr = interfaces;
        while(temp_addr != NULL) { 
            if(temp_addr->ifa_addr->sa_family == AF_INET) { 
                // Check if interface is en0 which is the wifi connection on the iPhone 
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) { 
                    // Get NSString from C String 
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                } 
            } 
            temp_addr = temp_addr->ifa_next; 
        } 
    } // Free memory 
    freeifaddrs(interfaces);
    return address;
}

#pragma mark - Memory management

- (id)init {
    if ((self = [super init])) {
        appDelegate = self;
    }
    return self;
}


- (void)dealloc
{
    [_window release];
    [_documentURLs release];
    [_query release];
    [_queue release];
    [_watchdog release];
    [super dealloc];
}

#pragma - AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[HTTPServer sharedHTTPServer] start];
    
    _watchdog = [[SGDirWatchdog alloc]initWithPath:[self localDocumentsURL].path update:^ {
        self.documentURLs = nil;
    }];
    [_watchdog start];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application 
           openURL:(NSURL *)url 
 sourceApplication:(NSString *)sourceApplication 
        annotation:(id)annotation {    
    if (url != nil && [url isFileURL]) {
#ifdef DEBUG
        NSLog(@"Try to add a file from an other application %s", __FUNCTION__);
#endif
        
        [self.queue addOperationWithBlock: ^{
            NSURL *baseURL = [self localDocumentsURL];
            NSURL *destinationURL = [baseURL URLByAppendingPathComponent:[url lastPathComponent]];
            
            
            [[NSFileManager defaultManager]moveItemAtURL:url toURL:destinationURL error:NULL];
            
            
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                self.documentURLs = nil;
            }];
        }];
    }
    
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [application beginBackgroundTaskWithExpirationHandler:^{
        [[HTTPServer sharedHTTPServer] stop];
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [_watchdog stop];
}

@end
