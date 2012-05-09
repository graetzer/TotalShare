//
//  AppTextFileResponse.m
//  TextTransfer
//
//  Created by Matt Gallagher on 2009/07/13.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "SGDownloadResponse.h"
#import "SGManager.h"
#import "SGAppDelegate.h"
#import "SGDocument.h"
#import "HTTPServer.h"

@implementation SGDownloadResponse

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
	return 2;
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
	if (components.count == 3 && [[components objectAtIndex:1] isEqualToString:@"download"])
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
    NSURL *urlPath = [SGDownloadResponse urlForName:name];
    SGDocument *document = [[SGDocument alloc]initWithFileURL:urlPath];
    
	NSData *fileData = [NSData dataWithContentsOfURL:document.fileURL];
    
    if (!fileData) {
        [super startResponse];// 501
        return;
    }

	CFHTTPMessageRef response =
		CFHTTPMessageCreateResponse(
			kCFAllocatorDefault, 200, NULL, kCFHTTPVersion1_1);
    
	CFHTTPMessageSetHeaderFieldValue(
		response, (CFStringRef)@"Content-Type", (CFStringRef)[SGManager mimeForPathExtension:[name pathExtension]]);
    
    CFHTTPMessageSetHeaderFieldValue(response,
                                     (CFStringRef)@"Content-Disposition",
                                     (CFStringRef)[NSString stringWithFormat:@"attachment; filename=%@;", name]);
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
        [document release];
	}
}

//
// pathForFile
//
// In this sample application, the only file returned by the server lives
// at a fixed location, whose path is returned by this method.
//
// returns the path of the text file.
//
+ (NSURL *)urlForName:(NSString *)name
{
	for (NSURL *url in appDelegate.documentURLs) {
        if ([url.lastPathComponent isEqualToString:name]) {
            return url;
        }
    }
    return nil;
}

@end
