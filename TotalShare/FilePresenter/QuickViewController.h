//
//  QuickViewController.h
//  TotalShare
//
//  Created by Simon Grätzer on 09.05.12.
//  Copyright (c) 2012 Graetzer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import "SGManager.h"

@interface QuickViewController : QLPreviewController <SGPresentationHandler, QLPreviewControllerDataSource, QLPreviewControllerDelegate>
@property (nonatomic, strong) NSURL *document;
@end
