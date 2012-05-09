
#import "EpubReaderViewController.h"
#import "EpubToolbar.h"
#import "DSActivityView.h"
#import "SGAppDelegate.h"


#define PAGING_AREA_WIDTH 48.0f

@interface  EpubReaderViewController (hidden)

- (void)unzipAndSaveFile;
- (NSString *)applicationDocumentsDirectory; 
- (void)loadPage;
- (NSString*)getRootFilePath;
- (void)setTitlename:(NSString*)titleText;

- (void)incrementPageNumber;
- (void)decrementPageNumber;

- (void)showMail;

@end

@implementation EpubReaderViewController
@synthesize ePubContent;
@synthesize rootPath = _rootPath;
@synthesize fileURL = _fileURL;

#pragma mark SGPesenationHandler
+ (void)load
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
	[SGManager registerHandler:self withExtension:@"epub"];
}

+ (UIViewController *)newInstanceWithURL:(NSURL *)url {
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

    EpubReaderViewController *viewC = [[EpubReaderViewController alloc] initWithURL:url];
    
	//readerViewController.delegate = self; // Set the ReaderViewController delegate to self
    return viewC;
}
#pragma mark - Init and real work

- (id)initWithURL:(NSURL *)url{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	assert(url != nil); // Ensure that the ReaderDocument object is not nil
    
	if ((self = [super initWithNibName:nil bundle:nil])) // Designated initializer
	{
        _fileURL = [url retain];
        
        [appDelegate.queue addOperationWithBlock:^{
           	//First unzip the epub file to documents directory
            [self unzipAndSaveFile];
            _xmlHandler=[[XMLHandler alloc] init];
            _xmlHandler.delegate=self;
            [_xmlHandler parseXMLFileAt:[self getRootFilePath]]; 
        }];
    }
    
	return self;
}

- (void)loadView {
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    [super loadView];
    
    _webview = [[UIWebView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:_webview];
    
    CGRect toolbarRect = self.view.bounds;
    toolbarRect.size.height = TOOLBAR_HEIGHT;
    _toolbar = [[EpubToolbar alloc]initWithFrame:toolbarRect];
    [self.view addSubview:_toolbar];
    
    [DSBezelActivityView activityViewForView:self.view withLabel:NSLocalizedString(@"loading", Loading string under an activity indicator)];
}

- (void)viewDidLoad {
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    [super viewDidLoad];
    
    //Setup Webview and the Scrollview
    UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	singleTapOne.numberOfTouchesRequired = 1; singleTapOne.numberOfTapsRequired = 1; singleTapOne.delegate = self;
    [_webview.scrollView addGestureRecognizer:singleTapOne];[singleTapOne release];
	[_webview setBackgroundColor:[UIColor clearColor]];
    _webview.scalesPageToFit = YES;
    _webview.scrollView.delaysContentTouches = NO;
    _webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Setup toolbar
    __block EpubReaderViewController *me = self;
    _toolbar.doneBlock = ^{
        [me dismissViewControllerAnimated:YES completion:nil];
    };
    _toolbar.emailBlock = ^{
        [me showMail];
    };
    
    [_toolbar setToolbarTitle:[self.fileURL.lastPathComponent stringByDeletingPathExtension]];
    
    // Setup look & feel
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    //Timer
    lastHideTime = [NSDate new];
}

/*Function Name : setTitlename
 *Return Type   : void
 *Parameters    : NSString- Text to set as title
 *Purpose       : To set the title for the view
 */

- (void)setTitlename:(NSString*)titleText{
	
	[_toolbar setToolbarTitle:titleText];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return UIInterfaceOrientationIsLandscape(toInterfaceOrientation) || toInterfaceOrientation == UIInterfaceOrientationPortrait;
    }
}

/*Function Name : unzipAndSaveFile
 *Return Type   : void
 *Parameters    : nil
 *Purpose       : To unzip the epub file to documents directory
*/

- (void)unzipAndSaveFile{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
	
	ZipArchive* za = [[ZipArchive alloc] init];
	if([za UnzipOpenFile:self.fileURL.path] ){
		
		NSString *strPath=[NSString stringWithFormat:@"%@/UnzippedEpub",[self applicationDocumentsDirectory]];
		//Delete all the previous files
		NSFileManager *filemanager=[[NSFileManager alloc] init];
		if ([filemanager fileExistsAtPath:strPath]) {
			
			NSError *error;
			[filemanager removeItemAtPath:strPath error:&error];
		}
		[filemanager release];
		filemanager=nil;
		//start unzip
		BOOL ret = [za UnzipFileTo:[NSString stringWithFormat:@"%@/",strPath] overWrite:YES];
		if( NO==ret ){
			// error handler here
			UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
														  message:@"An unknown error occured"
														 delegate:self
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
			[alert show];
			[alert release];
			alert=nil;
		}
		[za UnzipCloseFile];
	}					
	[za release];
}

#pragma mark - Utility
/*Function Name : applicationDocumentsDirectory
 *Return Type   : NSString - Returns the path to documents directory
 *Parameters    : nil
 *Purpose       : To find the path to documents directory
 */

- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

/*Function Name : getRootFilePath
 *Return Type   : NSString - Returns the path to container.xml
 *Parameters    : nil
 *Purpose       : To find the path to container.xml.This file contains the file name which holds the epub informations
 */

- (NSString*)getRootFilePath{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
	
	//check whether root file path exists
	NSFileManager *filemanager=[[NSFileManager alloc] init];
	NSString *strFilePath=[NSString stringWithFormat:@"%@/UnzippedEpub/META-INF/container.xml",[self applicationDocumentsDirectory]];
	if ([filemanager fileExistsAtPath:strFilePath]) {
		
		//valid ePub
		NSLog(@"Parse now");
		
		[filemanager release];
		filemanager=nil;
		
		return strFilePath;
	}
	else {
		
		//Invalid ePub file
		UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
													  message:@"Root File not Valid"
													 delegate:self
											cancelButtonTitle:@"OK"
											otherButtonTitles:nil];
		[alert show];
		[alert release];
		alert=nil;
		
	}
	[filemanager release];
	filemanager=nil;
	return @"";
}


#pragma mark XMLHandler Delegate Methods

- (void)foundRootPath:(NSString*)rootPath{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
	
	//Found the path of *.opf file
	
	//get the full path of opf file
	NSString *strOpfFilePath=[NSString stringWithFormat:@"%@/UnzippedEpub/%@",[self applicationDocumentsDirectory],rootPath];
	NSFileManager *filemanager=[[NSFileManager alloc] init];
	
	self.rootPath=[strOpfFilePath stringByReplacingOccurrencesOfString:[strOpfFilePath lastPathComponent] withString:@""];
	
	if ([filemanager fileExistsAtPath:strOpfFilePath]) {
		
		//Now start parse this file
		[_xmlHandler parseXMLFileAt:strOpfFilePath];
	}
	else {
		
		UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
													  message:@"OPF File not found"
													 delegate:self
											cancelButtonTitle:@"OK"
											otherButtonTitles:nil];
		[alert show];
		[alert release];
		alert=nil;
	}
	[filemanager release];
	filemanager=nil;
	
}


- (void)finishedParsing:(EpubContent*)ePubContents{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	_pagesPath=[NSString stringWithFormat:@"%@/%@",self.rootPath,[ePubContents._manifest valueForKey:[ePubContents._spine objectAtIndex:0]]];
	self.ePubContent=ePubContents;
	_pageNumber=0;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self loadPage];
        [DSBezelActivityView removeViewAnimated:YES];
    }];
}


/*Function Name : loadPage
 *Return Type   : void 
 *Parameters    : nil
 *Purpose       : To load actual pages to webview
 */

- (void)loadPage{
	
	_pagesPath=[NSString stringWithFormat:@"%@/%@",self.rootPath,[self.ePubContent._manifest valueForKey:[self.ePubContent._spine objectAtIndex:_pageNumber]]];
	[_webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:_pagesPath]]];
	//set page number
	//_pageNumberLbl.text=[NSString stringWithFormat:@"%d",_pageNumber+1];
}

#pragma mark Actions

- (void)incrementPageNumber {
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
    if ([self.ePubContent._spine count]-1>_pageNumber) {
        
        _pageNumber++;
        [self loadPage];
    }
}

- (void)decrementPageNumber {
    
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
    if (_pageNumber>0) {
        
        _pageNumber--;
        [self loadPage];
    }
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	//if ([touch.view isKindOfClass:[UIScrollView class]]) return YES;
    
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer; {
    #ifdef DEBUG
        NSLog(@"%s", __FUNCTION__);
    #endif
    return YES;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds
        
		CGPoint point = [recognizer locationInView:recognizer.view];
        
		CGRect areaRect = CGRectInset(viewRect, PAGING_AREA_WIDTH, 0.0f);
        
		if (CGRectContainsPoint(areaRect, point)) // Tap is inside this area
		{
			if ([lastHideTime timeIntervalSinceNow] < -0.8) // Delay since hide
			{
				if (_toolbar.hidden == YES)// || (mainPagebar.hidden == YES))
				{
					[_toolbar showToolbar];// [mainPagebar showPagebar]; // Show
				} else {
                    [_toolbar hideToolbar];
                    
                    [lastHideTime release]; lastHideTime = [NSDate new];

                }
			}
            
			return;
		}
        
		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = PAGING_AREA_WIDTH;
		nextPageRect.origin.x = (viewRect.size.width - PAGING_AREA_WIDTH);
        
		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
			[self incrementPageNumber]; return;
		}
        
		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = PAGING_AREA_WIDTH;
        
		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			[self decrementPageNumber]; return;
		}
	}
}

#pragma mark - Mail
- (void)showMail
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	if ([MFMailComposeViewController canSendMail] == NO) return;
    
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.fileURL.path error:NULL];
    
	unsigned long long fileSize = [[fileAttributes objectForKey:NSFileSize] unsignedLongLongValue];
    
	if (fileSize < (unsigned long long)15728640) // Check attachment size limit (15MB)
	{
		NSURL *fileURL = self.fileURL; NSString *fileName = self.fileURL.lastPathComponent; // Document
        
		NSData *attachment = [NSData dataWithContentsOfURL:fileURL options:(NSDataReadingMapped|NSDataReadingUncached) error:nil];
        
		if (attachment != nil) // Ensure that we have valid document file attachment data
		{
			MFMailComposeViewController *mailComposer = [MFMailComposeViewController new];
            
			[mailComposer addAttachmentData:attachment mimeType:@"application/epub+zip" fileName:fileName];
            
			[mailComposer setSubject:fileName]; // Use the document file name for the subject
            
			mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
			mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;
            
			mailComposer.mailComposeDelegate = self; // Set the delegate
            
			[self presentViewController:mailComposer animated:YES completion:nil];
            
			[mailComposer release]; // Cleanup
		}
	}
	else // The document file is too large to email alert
	{
		UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FileTooLargeTitle", @"text")
                                                           message:NSLocalizedString(@"FileTooLargeMessage", @"text") delegate:NULL
                                                 cancelButtonTitle:NSLocalizedString(@"OK", @"button") otherButtonTitles:nil];
        
		[theAlert show]; [theAlert release]; // Show and cleanup
	}

}

#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
#ifdef DEBUG
	if ((result == MFMailComposeResultFailed) && (error != NULL)) NSLog(@"%@", error);
#endif
    
	[self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark Memory handlers

- (void)didReceiveMemoryWarning {
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	[_toolbar release];
    _toolbar = nil;
    
    [lastHideTime release];
    lastHideTime = nil;
    
	[_webview release];
	_webview=nil;
	
	[ePubContent release];
	ePubContent=nil;
	
	_pagesPath=nil;
	_rootPath=nil;
	
	[_fileURL release];
	_fileURL = nil;
	
    [super dealloc];
}

@end
