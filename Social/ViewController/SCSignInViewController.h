#import <UIKit/UIKit.h>

@protocol SCSignInViewControllerDelegate <NSObject>

- (void)loginSuccess;

@end

@interface SCSignInViewController : UIViewController

@property (nonatomic, weak) id<SCSignInViewControllerDelegate> delegate;
@end
