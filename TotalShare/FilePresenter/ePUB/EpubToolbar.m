

#import "EpubToolbar.h"

@implementation EpubToolbar

#pragma mark Constants

#define TITLE_Y 8.0f
#define TITLE_X 12.0f
#define TITLE_HEIGHT 28.0f

#define DONE_BUTTON_WIDTH 56.0f
#define EMAIL_BUTTON_WIDTH 44.0f

#define READER_ENABLE_MAIL TRUE

#pragma mark Properties
@synthesize doneBlock = _doneBlock;
@synthesize emailBlock = _emailBlock;


#pragma mark ReaderMainToolbar instance methods

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super initWithFrame:frame]))
	{
		self.translucent = YES;
		self.barStyle = UIBarStyleBlack;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		NSMutableArray *toolbarItems = [NSMutableArray new]; NSUInteger buttonCount = 0;

		CGFloat titleX = TITLE_X; CGFloat titleWidth = (self.bounds.size.width - (titleX * 2.0f));


		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"button")
										style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];

		[toolbarItems addObject:doneButton]; [doneButton release]; buttonCount++; titleX += DONE_BUTTON_WIDTH; titleWidth -= DONE_BUTTON_WIDTH;

		UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];

		[toolbarItems addObject:flexSpace]; [flexSpace release];
        
#if (READER_ENABLE_MAIL == TRUE) // Option
        
		if ([MFMailComposeViewController canSendMail] == YES)
		{
			UIBarButtonItem *emailButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Reader-Email.png"]
                                                                            style:UIBarButtonItemStyleBordered target:self action:@selector(emailButtonTapped:)];
            
			[toolbarItems addObject:emailButton]; [emailButton release]; buttonCount++; titleWidth -= EMAIL_BUTTON_WIDTH;
		}
        
#endif // end of READER_ENABLE_MAIL Option
        

		if (buttonCount > 0) [self setItems:toolbarItems animated:NO]; [toolbarItems release];

		CGRect titleRect = CGRectMake(titleX, TITLE_Y, titleWidth, TITLE_HEIGHT);

		theTitleLabel = [[UILabel alloc] initWithFrame:titleRect];

		theTitleLabel.textAlignment = UITextAlignmentCenter;
		theTitleLabel.font = [UIFont systemFontOfSize:20.0f];
		theTitleLabel.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
		theTitleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		theTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		theTitleLabel.backgroundColor = [UIColor clearColor];
		theTitleLabel.adjustsFontSizeToFitWidth = YES;
		theTitleLabel.minimumFontSize = 14.0f;

		[self addSubview:theTitleLabel];
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

    self.doneBlock = nil;
	[theTitleLabel release], theTitleLabel = nil;

	[super dealloc];
}

- (void)setToolbarTitle:(NSString *)title
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[theTitleLabel setText:title];
}

- (void)hideToolbar
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	if (self.hidden == NO)
	{
		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.alpha = 0.0f;
			}
			completion:^(BOOL finished)
			{
				self.hidden = YES;
			}
		];
	}
}

- (void)showToolbar
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	if (self.hidden == YES)
	{
		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.hidden = NO;
				self.alpha = 1.0f;
			}
			completion:NULL
		];
	}
}

#pragma mark UIBarButtonItem action methods

- (void)doneButtonTapped:(UIBarButtonItem *)button
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

    self.doneBlock();
	//[delegate tappedInToolbar:self doneButton:button];
}

- (void)emailButtonTapped:(UIBarButtonItem *)button
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	self.emailBlock();
}
@end
