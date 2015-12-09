#import "WAApplicationViewController.h"
#import "WAAuthViewController.h"

@interface WAApplicationViewController () <WAAuthViewControllerDelegate, WARemoteMediatorOperationDelegate>

@property (nonatomic, strong) WAAuthViewController *authViewController;
@property (nonatomic, strong) UINavigationController *authNavigationController;

@end

@implementation WAApplicationViewController

@synthesize authViewController, authNavigationController;

static WAApplicationViewController *sharedApplicationViewController;

#pragma mark - ClassMethods

+ (WAApplicationViewController *)sharedApplicationViewController
{
	return sharedApplicationViewController;
}

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        sharedApplicationViewController = [[WAApplicationViewController alloc] init];
    }
}

#pragma mark - Helper Methods

- (void)showAuth
{
    self.authViewController = nil;
    
    /* Reset Cookie Storage */
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    
    for (NSHTTPCookie *cookie in cookies)
    {
        [cookieStorage deleteCookie:cookie];
    }
    
    self.authViewController = [[WAAuthViewController alloc] initWithAuthorisationURL:@"http://secure.merchantstack.com/"
                                                                            tokenURL:@"oauth/token"
                                                                            clientId:@"ASK KARTHIK FOR NEW APP CLIENT ID"
                                                                        clientSecret:@"ASK KARTHIK FOR NEW APP CLIENT SECRET"
                                                                         redirectURI:@"http://www.google.com/OAuthCallback"];
                                                                         
    self.authViewController.scope = @"user,application,merchant,store,product,category,basket,promotion";
    self.authViewController.delegate = self;
    
    self.authNavigationController = [[UINavigationController alloc] initWithRootViewController:self.authViewController];
    self.authNavigationController.view.frame = self.view.bounds;
    self.authNavigationController.view.alpha = 0.0;
}

- (void)productsOperation withAccessToken:(NSString *)accessToken
{
    WAProductParser *productParser = [[WAProductParser alloc] init];
    
    WAUrl *productUrl = [[WAUrl alloc] init];
    productUrl.domain = [[WAAppSettings sharedSettings] shopwaveApiUrlString];
    productUrl.type = WAUrlFetchTypeProducts;
    productUrl.method = WAUrlRequestMethodGet;
    [productUrl addHeaders:[[WAAppSettings sharedSettings] shopwaveDefaultGetUrlHeaders]];
    
    if (accessToken != nil)
    {
        NSString *headerString = [NSString stringWithFormat:@"OAuth %@", accessToken];
        [productUrl setHeader:headerString forKey:@"Authorization"];
        
        WARemoteMediatorOperation *remoteMediatorOperation = [[WARemoteMediatorOperation alloc] init];
        remoteMediatorOperation.parser = productParser;
        remoteMediatorOperation.url = productUrl;
    
        return remoteMediatorOperation;
    }
    
    WAMerchantStackRemoteMediatorOperation *remoteMediatorOperation = [[WAMerchantStackRemoteMediatorOperation alloc] init];
    remoteMediatorOperation.parser = productParser;
    remoteMediatorOperation.url = productUrl;
    remoteMediatorOperation.delegate = self;
    [remoteMediatorOperation fetch];
}

#pragma mark - WARemoteMediatorOperationDelegate Methods

- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didRefreshAllProducts:(NSDictionary *)products
{
    //we have some new products
}

- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didNotFetchWithError:(NSError *)error
{
    //an error has occurred
}

#pragma mark - WAAuthViewControllerDelegate Methods

- (void)authViewController:(WAAuthViewController *)authViewController didFailWithError:(NSError *)error
{
	//an error has occurred
}

- (void)authViewController:(WAAuthViewController *)authViewController didAuthoriseWithAuth:(WAUnmanagedAuth *)auth
{
	//we have auth details ready to make API call
}


@end
