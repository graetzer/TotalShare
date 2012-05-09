//
//  SGPresentationManager.h
//  TotalShare
//
//  Created by Simon Grätzer on 21.09.12.
//  Copyright (c) 2012 Simon Grätzer. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SGPresentationHandler
@required
+ (UIViewController *)newInstanceWithURL:(NSURL *)url;

@optional
+ (void)deleteMetadata:(NSURL *)url;

@end

@interface SGManager : NSObject

+ (void)registerHandler:(Class<SGPresentationHandler>)handlerClass withExtension:(NSString *)extension;

+ (UIViewController *)newControllerForURL:(NSURL *)url;

+ (void)deleteMetadata:(NSURL *)url;

+ (NSString *)mimeForPathExtension:(NSString *)pathExtension;

+ (NSArray *)supportedFiles;

@end