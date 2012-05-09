//
//  SGDetailViewController.h
//  iLibrary
//
//  Created by Simon Grätzer on 20.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SGDocument.h"

@interface SGDetailViewController : UIViewController <SGDocumentDelegate, UISplitViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) SGDocument *document;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) UIPopoverController *documentPopoverController;
@property (nonatomic) CGFloat keyboardHeight;

@end
