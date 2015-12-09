#import <UIKit/UIKit.h>

@class WAAuthViewController;

@interface WAApplicationViewController : UIViewController
{
    @private
    WAAuthViewController *authViewController;
    UINavigationController *authNavigationController;
}

#pragma mark - ClassMethods
+ (WAApplicationViewController *)sharedApplicationViewController;

#pragma mark - Helper Methods
- (void)showAuth;

@end
