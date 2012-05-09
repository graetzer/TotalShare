

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "ZipArchive.h" 
#import "XMLHandler.h"
#import "EpubContent.h"
#import "SGManager.h"

@class EpubToolbar;

@interface EpubReaderViewController : UIViewController<XMLHandlerDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, SGPresentationHandler> {

	UIWebView *_webview;
	EpubToolbar *_toolbar;
    NSDate *lastHideTime;
    XMLHandler *_xmlHandler;
	EpubContent *ePubContent;
	NSString *_pagesPath;
	int _pageNumber;
}

@property (nonatomic, retain)EpubContent *ePubContent;
@property (nonatomic, retain)NSString *rootPath;
@property (nonatomic, readonly) NSURL *fileURL;


- (id)initWithURL:(NSURL *)url;
@end

