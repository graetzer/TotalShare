

#import "EpubContent.h"

@implementation EpubContent

@synthesize _manifest;
@synthesize _spine;

- (void) dealloc{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[_manifest release];
	_manifest=nil;
	[_spine release];
	_spine=nil; 
	[super dealloc];
}

@end
