//
//  SGMasterViewController.m
//  TotalShare
//
//  Created by Simon Grätzer on 20.03.12.
//  Copyright (c) 2012 Simon Grätzer. All rights reserved.
//

#import "SGMasterViewController.h"
#import "SGAppDelegate.h"
#import "SGManager.h"
#import "SGDocument.h"
#import "SGCell.h"
#import "NSURL+Cloud.h"


@implementation SGMasterViewController
@synthesize currentDocument;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@:8080", [appDelegate getIPAddress]];//TODO
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [appDelegate.query enableUpdates];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [appDelegate.query disableUpdates];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return appDelegate.documentURLs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SGCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    NSURL *url = [appDelegate.documentURLs objectAtIndex:indexPath.row];
    cell.titleLabel.text = [url.lastPathComponent stringByDeletingPathExtension];
    cell.cloudSwitch.on = url.isCloud;
    cell.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *pathURL = [appDelegate.documentURLs objectAtIndex:indexPath.row];
    SGDocument *document = [[SGDocument alloc] initWithFileURL:pathURL];
    UIViewController *viewC = [SGManager newControllerForURL:document.fileURL];
    self.currentDocument = document;
    [document release];

    //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        viewC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:viewC animated:YES completion:nil];
    //}
    [viewC release];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([[segue identifier] isEqualToString:@"showDocument"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSURL *url = [self.documentURLs objectAtIndex:indexPath.row];
//        SGDocument *document = [[[SGDocument alloc] initWithFileURL:url] autorelease];
//        [[segue destinationViewController] setDocument:document];
//    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSURL *url = [appDelegate.documentURLs objectAtIndex:indexPath.row];
//        if ([self.detailViewController.document.fileURL isEqual:url]) {
//            [self showDocument:nil];
//        }
        [appDelegate deleteURL:url];

        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Documents

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
//    NSURL *documentURL = self.detailViewController.document.fileURL;
//    if (documentURL) {
//        NSUInteger row = [self.documentURLs indexOfObject:documentURL];
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
//        [self.tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:UITableViewScrollPositionNone];
//    }
}
- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
