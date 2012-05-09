//
//  SGPresentationManager.m
//  TotalShare
//
//  Created by Simon Grätzer on 21.09.12.
//  Copyright (c) 2012 Simon Grätzer. All rights reserved.
//

#import "SGManager.h"

@implementation SGManager
static NSMutableDictionary *registeredHandlers = nil;

//
// registerHandler:
//
// Inserts the HTTPResponseHandler class into the priority list.
//
+ (void)registerHandler:(Class<SGPresentationHandler>)handlerClass withExtension:(NSString *)extension;
{
	if (registeredHandlers == nil)
	{
		registeredHandlers = [[NSMutableDictionary alloc] init];
	}
	
	[registeredHandlers setObject:handlerClass forKey:extension];
}

+ (UIViewController *)newControllerForURL:(NSURL *)url; {
    NSString *extension = url.pathExtension;
    Class<SGPresentationHandler> cobj = [registeredHandlers objectForKey:extension];
    return [cobj newInstanceWithURL:url];
}

+ (void)deleteMetadata:(NSURL *)url; {
    NSString *extension = url.pathExtension;
    Class<SGPresentationHandler> cobj = [registeredHandlers objectForKey:extension];
    [cobj deleteMetadata:url];
}

+ (NSString *)mimeForPathExtension:(NSString *)pathExtension; {
    
    
    if ([pathExtension isEqualToString:@"pdf"]) {
        return @"application/pdf";
    } else if ([pathExtension isEqualToString:@"epub"]) {
        return @"application/epub+zip";
    } else if ([pathExtension isEqualToString:@"png"]) {
        return @"image/png";
    } else if ([pathExtension isEqualToString:@"css"]){
        return @"text/css";
    } else {
        return @"text/plain";
    }
}

+ (NSArray *)supportedFiles {
    return [registeredHandlers allKeys];
}

@end