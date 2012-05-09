//
//  StaticFileResolver.h
//  TotalShare
//
//  Created by Simon Grätzer on 21.09.12.
//  Copyright (c) 2012 Simon Grätzer. All rights reserved.
//

#import "HTTPResponseHandler.h"

@interface SGStaticResponse : HTTPResponseHandler

+ (NSString *)pathForName:(NSString *)name;

@end
