//
//  NSArray+Globbing_h.h
//  TotalShare
//
//  Created by Simon Grätzer on 26.09.12.
//  Copyright (c) 2012 Simon Grätzer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Globbing)

+ (NSArray*) arrayWithURLsMatchingPattern: (NSString*) pattern inDirectory: (NSString*) directory;

@end