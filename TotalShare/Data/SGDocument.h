//
//  SGDocument.h
//  TotalShare
//
//  Created by Simon Grätzer on 20.03.12.
//  Copyright (c) 2012 Simon Grätzer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGDocument;

/*
 * Custom subclass of UIDocument
 * The doc say's you have to subclass UIDocument, but it's actually not nessesary for this app, beause the documents won't change
 */
@interface SGDocument : UIDocument

@end
