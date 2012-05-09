//
//  NSURL+Cloud.m
//  TotalShare
//
//  Created by Simon Grätzer on 26.09.12.
//  Copyright (c) 2011 Cyber:con GmbH. All rights reserved.
//

#import "NSURL+Cloud.h"

@implementation NSURL (Cloud)
@dynamic isCloud;

- (BOOL)isCloud {
    return [[NSFileManager defaultManager]isUbiquitousItemAtURL:self];
}

@end
