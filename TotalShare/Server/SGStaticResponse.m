//
//  StaticFileResolver.m
//  TotalShare
//
//  Created by Simon Grätzer on 21.09.12.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SGStaticResponse.h"
#import "SGManager.h"
#import "HTTPServer.h"

@implementation SGStaticResponse
//
// load
//
// Implementing the load method and invoking
// [HTTPResponseHandler registerHandler:self] causes HTTPResponseHandler
// to register this class in the list of registered HTTP response handlers.
//
+ (void)load
{
	[HTTPResponseHandler registerHandler:self];
}

+ (NSUInteger)priority
{
	return 1;
}

//
// canHandleRequest:method:url:headerFields:
//
// Class method to determine if the response handler class can handle
// a given request.
//
// Parameters:
//    aRequest - the request
//    requestMethod - the request method
//    requestURL - the request URL
//    requestHeaderFields - the request headers
//
// returns YES (if the handler can handle the request), NO (otherwise)
//
+ (BOOL)canHandleRequest:(CFHTTPMessageRef)aRequest
                  method:(NSString *)requestMethod
                     url:(NSURL *)requestURL
            headerFields:(NSDictionary *)requestHeaderFields
{
    NSArray *components = requestURL.pathComponents;
	if (components.count == 3 && [[components objectAtIndex:1] isEqualToString:@"public"])
	{
		return YES;
	}
	
	return NO;
}

//
// startResponse
//
// Since this is a simple response, we handle it synchronously by sending
// everything at once.
//
- (void)startResponse
{
    NSString *name = [url.path.pathComponents lastObject];
    NSString *path = [SGStaticResponse pathForName:name];
	NSData *fileData = [NSData dataWithContentsOfFile:path];
    
    if (!fileData) {
        [super startResponse];// 501
        return;
    }
	CFHTTPMessageRef response =
    CFHTTPMessageCreateResponse(
                                kCFAllocatorDefault, 200, NULL, kCFHTTPVersion1_1);
    
	CFHTTPMessageSetHeaderFieldValue(
                                     response, (CFStringRef)@"Content-Type", (CFStringRef)[SGManager mimeForPathExtension:[name pathExtension]]);
    
	CFHTTPMessageSetHeaderFieldValue(
                                     response, (CFStringRef)@"Connection", (CFStringRef)@"close");
	CFHTTPMessageSetHeaderFieldValue(
                                     response,
                                     (CFStringRef)@"Content-Length",
                                     (CFStringRef)[NSString stringWithFormat:@"%ld", [fileData length]]);
	CFDataRef headerData = CFHTTPMessageCopySerializedMessage(response);
    
	@try
	{
		[fileHandle writeData:(NSData *)headerData];
		[fileHandle writeData:fileData];
	}
	@catch (NSException *exception)
	{
		// Ignore the exception, it normally just means the client
		// closed the connection from the other end.
	}
	@finally
	{
		CFRelease(headerData);
		[server closeHandler:self];
	}
}

static NSString *htmlBundlePath = nil;

//
// pathForFile
//
// In this sample application, the only file returned by the server lives
// at a fixed location, whose path is returned by this method.
//
// returns the path of the text file.
//
+ (NSString *)pathForName:(NSString *)name
{
    if (!htmlBundlePath) {
        htmlBundlePath = [[[NSBundle mainBundle] pathForResource:@"html" ofType:@"bundle"] retain];
    }
    
	return [htmlBundlePath stringByAppendingPathComponent:name];
}

@end
