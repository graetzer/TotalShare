//
//  SGMasterViewController.h
//  TotalShare
//
//  Created by Simon Grätzer on 20.03.12.
//  Copyright (c) 2012 Simon Grätzer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGDetailViewController, SGDocument;

@interface SGMasterViewController : UITableViewController
@property (nonatomic, strong) SGDocument *currentDocument;
@end
