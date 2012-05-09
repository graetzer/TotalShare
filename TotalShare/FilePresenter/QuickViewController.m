//
//  QuickViewController.m
//  TotalShare
//
//  Created by Simon Grätzer on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuickViewController.h"

@interface QuickViewController ()

@end

@implementation QuickViewController
@synthesize document;

+ (void)load
{
	[SGManager registerHandler:self withExtension:@"doc"];
    [SGManager registerHandler:self withExtension:@"pages"];
    [SGManager registerHandler:self withExtension:@"key"];
    [SGManager registerHandler:self withExtension:@"numbers"];
    //[SGManager registerHandler:self withExtension:@"pdf"]; // Got an alternative implementation
    
    [SGManager registerHandler:self withExtension:@"png"];
    [SGManager registerHandler:self withExtension:@"jpg"];
    [SGManager registerHandler:self withExtension:@"jpeg"];
    
    [SGManager registerHandler:self withExtension:@"rtf"];
    [SGManager registerHandler:self withExtension:@"txt"];
    [SGManager registerHandler:self withExtension:@"csv"];
    
}

+ (UIViewController *)newInstanceWithURL:(NSURL *)url {
    assert(url != nil);
    
    QuickViewController *me = [[QuickViewController alloc]initWithNibName:nil bundle:nil];
    me.document = url;
    //me.delegate = me;
    me.dataSource = me;

    return me;
}

+ (void)deleteMetadata:(NSURL *)url {
}

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller {
    return 1;
}

- (id <QLPreviewItem>) previewController: (QLPreviewController *) controller previewItemAtIndex: (NSInteger) index; {
    return self.document;
}
@end
