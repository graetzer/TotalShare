

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#define TOOLBAR_HEIGHT 44.0f

@interface EpubToolbar : UIToolbar
{
@private // Instance variables

	UILabel *theTitleLabel;
}

@property (nonatomic, copy) void (^doneBlock)(void);
@property (nonatomic, copy) void (^emailBlock)(void);

- (void)setToolbarTitle:(NSString *)title;

- (void)hideToolbar;
- (void)showToolbar;

@end
