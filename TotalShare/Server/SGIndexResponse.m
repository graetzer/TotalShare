//
//  SGDocumentsResponse.m
//  TotalShare
//
//  Created by Simon Grätzer on 21.09.12.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SGIndexResponse.h"
#import "SGManager.h"
#import "HTTPServer.h"
#import "SGStaticResponse.h"
#import "SGAppDelegate.h"

@implementation SGIndexResponse

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
	if ([requestURL.path isEqualToString:@"/"])
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
    NSString *path = [SGStaticResponse pathForName:@"index.html"];
    NSMutableString *index = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity:200];
    
    NSRange start = [index rangeOfString:@"${list}"];
    NSRange end = [index rangeOfString:@"${/list}"];
    NSRange templateRange = NSMakeRange(start.location + start.length, end.location - start.location - start.length);
    NSString *template = [index substringWithRange:templateRange];
    
    for (NSURL *document in appDelegate.documentURLs) {
        [buffer appendFormat:template, document.lastPathComponent];
    }
    
    templateRange = NSMakeRange(start.location, end.location + end.length - start.location);
    [index replaceCharactersInRange:templateRange withString:buffer];
    
    NSData *fileData = [index dataUsingEncoding:NSUTF8StringEncoding];
    if (!fileData) {
        [super startResponse];// 501
        return;
    }
	CFHTTPMessageRef response =
    CFHTTPMessageCreateResponse(
                                kCFAllocatorDefault, 200, NULL, kCFHTTPVersion1_1);
    
	CFHTTPMessageSetHeaderFieldValue(
                                     response, (CFStringRef)@"Content-Type", (CFStringRef)@"text/html");
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
@end
