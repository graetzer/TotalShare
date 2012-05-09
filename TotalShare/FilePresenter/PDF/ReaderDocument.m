//
//	ReaderDocument.m
//	Reader v2.0.0
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011 Julius Oklamcak. All rights reserved.
//
//	This work is being made available under a Creative Commons Attribution license:
//		«http://creativecommons.org/licenses/by/3.0/»
//	You are free to use this work and any derivatives of this work in personal and/or
//	commercial products and projects as long as the above copyright is maintained and
//	the original author is attributed.
//

#import "ReaderDocument.h"
#import "CGPDFDocument.h"

@implementation ReaderDocument

#pragma mark Properties

@synthesize fileDate = _fileDate;
@synthesize fileSize = _fileSize;
@synthesize pageCount = _pageCount;
@synthesize pageNumber = _pageNumber;
@synthesize lastOpen = _lastOpen;
@synthesize password = _password;
@synthesize fileURL = _fileURL;
@dynamic fileName;

#pragma mark ReaderDocument class methods

+ (NSString *)documentsPath
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);

	return [documentsPaths objectAtIndex:0]; // Path to the application's "Documents" directory
}

+ (NSString *)archiveFilePath:(NSString *)filename
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	assert(filename != nil); // Ensure that the archive file name is not nil

	NSString *documentsPath = [ReaderDocument documentsPath]; // Application's "Documents" path

	NSString *archiveName = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"];

	return [documentsPath stringByAppendingPathComponent:archiveName]; // "~/Documents/'filename'.plist"
}

+ (ReaderDocument *)unarchiveFromFileName:(NSString *)filename
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	ReaderDocument *document = nil;

	NSString *archiveFilePath = [ReaderDocument archiveFilePath:filename];

	@try // To unarchive an archived ReaderDocument object from its property list
	{
		document = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveFilePath];
	}
	@catch (NSException *exception) // Exception handling (just in case O_o)
	{
		#ifdef DEBUG
			NSLog(@"%s Caught %@: %@", __FUNCTION__, [exception name], [exception reason]);
		#endif
	}

	return document;
}

+ (BOOL)purgeWithFileName:(NSString *) filename{
    NSString *archiveFilePath = [ReaderDocument archiveFilePath:filename];
    return [[NSFileManager defaultManager]removeItemAtPath:archiveFilePath error:NULL];
}

#pragma mark ReaderDocument instance methods

- (id)initWithURL:(NSURL *)url password:(NSString *)phrase;
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super init]))
	{
		assert(url != nil); // Ensure that the full file path is not nil

		_password = [phrase copy]; // Keep a copy of any given document password

		_pageNumber = [[NSNumber numberWithInteger:1] retain]; // Start page 1

		_fileURL = url;

		CGPDFDocumentRef thePDFDocRef = CGPDFDocumentCreateX((CFURLRef) url, _password);

		if (thePDFDocRef != NULL) // Get the number of pages in a document
		{
			NSInteger pageCount = CGPDFDocumentGetNumberOfPages(thePDFDocRef);

			_pageCount = [[NSNumber numberWithInteger:pageCount] retain];

			CGPDFDocumentRelease(thePDFDocRef); // Cleanup
		}
		else // Cupertino, we have a problem with the document...
		{
			NSAssert(NO, @"thePDFDocRef == NULL"); //abort();
		}

		_lastOpen = [[NSDate dateWithTimeIntervalSinceReferenceDate:0.0] retain];

		NSFileManager *fileManager = [[NSFileManager new] autorelease]; // File manager

		NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:url.path error:NULL];

		_fileDate = [[fileAttributes objectForKey:NSFileModificationDate] retain]; // File date

		_fileSize = [[fileAttributes objectForKey:NSFileSize] retain]; // File size
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[_fileURL release], _fileURL = nil;

	[_password release], _password = nil;

	[_pageNumber release], _pageNumber = nil;

	[_pageCount release], _pageCount = nil;

	[_fileSize release], _fileSize = nil;

	[_fileDate release], _fileDate = nil;

	[_lastOpen release], _lastOpen = nil;

	[super dealloc];
}

- (NSString *)fileName
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	return [_fileURL lastPathComponent];
}

- (BOOL)archiveWithFileName:(NSString *)filename
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	NSString *archiveFilePath = [ReaderDocument archiveFilePath:filename];

	return [NSKeyedArchiver archiveRootObject:self toFile:archiveFilePath];
}

- (void)saveReaderDocument
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[self archiveWithFileName:self.fileName];
}

#pragma mark NSCoding protocol methods

- (void)encodeWithCoder:(NSCoder *)encoder
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[encoder encodeObject:_fileURL forKey:@"FileURL"];

	[encoder encodeObject:_fileDate forKey:@"FileDate"];

	[encoder encodeObject:_pageCount forKey:@"PageCount"];

	[encoder encodeObject:_pageNumber forKey:@"PageNumber"];

	[encoder encodeObject:_fileSize forKey:@"FileSize"];

	[encoder encodeObject:_lastOpen forKey:@"LastOpen"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	_fileURL = [decoder decodeObjectForKey:@"FileURL"];

	_fileDate = [decoder decodeObjectForKey:@"FileDate"];

	_pageCount = [decoder decodeObjectForKey:@"PageCount"];

	_pageNumber = [decoder decodeObjectForKey:@"PageNumber"];

	_fileSize = [decoder decodeObjectForKey:@"FileSize"];

	_lastOpen = [decoder decodeObjectForKey:@"LastOpen"];

	[_fileURL retain]; // Retain fileName object

	[_fileDate retain]; // Retain fileDate object

	[_pageCount retain]; // Retain pageCount object

	[_pageNumber retain]; // Retain pageNumber object

	[_fileSize retain]; // Retain fileSize object

	[_lastOpen retain]; // Retain lastOpen object

	return self;
}

@end
