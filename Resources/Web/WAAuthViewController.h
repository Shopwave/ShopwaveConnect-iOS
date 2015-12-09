#import <UIKit/UIKit.h>

@class WARemoteMediatorOperation, WAUnmanagedAuth;

@protocol WAAuthViewControllerDelegate;

@interface WAAuthViewController : UIViewController
{
    NSString *scope;
    __weak id <WAAuthViewControllerDelegate> delegate;
    
    @private
    UIWebView *webView;
    NSString *clientId;
    NSString *clientSecret;
    NSString *authorizationURL;
    NSString *tokenURL;
    NSString *redirectURI;
    WARemoteMediatorOperation *accessTokenOperation;
    UIActivityIndicatorView *activityIndicatorView;
}

@property (nonatomic, strong) NSString *scope;
@property (nonatomic, weak) id <WAAuthViewControllerDelegate> delegate;

- (WAAuthViewController *)initWithAuthorisationURL:(NSString *)newAuthorizationURL tokenURL:(NSString *)newTokenURL clientId:(NSString *)newClientId clientSecret:(NSString *)newClientSecret redirectURI:(NSString *)newRedirectURI;

#pragma mark - PublicHelper Methods
+ (NSString *)encodedOAuthValueForString:(NSString *)str;
- (void)setFrame:(CGRect)frame;
- (void)stopLoading;

@end

@protocol WAAuthViewControllerDelegate <NSObject>

- (void)authViewController:(WAAuthViewController *)authViewController didAuthoriseWithAuth:(WAUnmanagedAuth *)auth;
- (void)authViewController:(WAAuthViewController *)authViewController didFailWithError:(NSError *)error;

@end
