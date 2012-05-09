//
//  NSArray+Globbing_h.m
//  TotalShare
//
//  Created by Simon Grätzer on 26.09.12.
//  Copyright (c) 2012 Simon Grätzer. All rights reserved.
//

#import "NSArray+Globbing_h.h"
#include <glob.h>

@implementation NSArray (Globbing)

+ (NSArray*) arrayWithURLsMatchingPattern: (NSString*) pattern inDirectory: (NSString*) directory {
    
    NSMutableArray* files = [NSMutableArray array];
    glob_t gt;
    NSString* globPathComponent = [NSString stringWithFormat: @"/%@", pattern];
    NSString* expandedDirectory = [directory stringByExpandingTildeInPath];
    const char* fullPattern = [[expandedDirectory stringByAppendingPathComponent: globPathComponent] UTF8String];
    if (glob(fullPattern, 0, NULL, &gt) == 0) {
        int i;
        for (i=0; i<gt.gl_matchc; i++) {
            int len = strlen(gt.gl_pathv[i]);
            NSString* filename = [[NSFileManager defaultManager] stringWithFileSystemRepresentation: gt.gl_pathv[i] length: len];
            [files addObject:[NSURL fileURLWithPath:filename]];
        }
    }
    globfree(&gt);
    return [NSArray arrayWithArray: files];
}

@end

