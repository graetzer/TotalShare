//
//  SGAppDelegate.h
//  TotalShare
//
//  Created by Simon Grätzer on 20.03.12.
//  Copyright (c) 2012 Simon Grätzer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGDirWatchdog;
@interface SGAppDelegate : UIResponder <UIApplicationDelegate> {
    SGDirWatchdog *_watchdog;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSMutableArray *documentURLs;
@property (strong, nonatomic) NSMetadataQuery *query;
@property (readonly) NSOperationQueue *queue;


- (NSURL *)localDocumentsURL;
- (NSURL *)ubiquitousDocumentsURL;

- (BOOL)updateURL:(NSURL *) url setUbiquitous:(BOOL)ubitiqous;
- (void)deleteURL:(NSURL *)url;

- (NSString *)getIPAddress;

@end

extern SGAppDelegate *appDelegate;