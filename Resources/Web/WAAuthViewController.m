#import "WAAuthViewController.h"
#import "WAUrl.h"
#import "WAAuthParser.h"
#import "WARemoteMediatorOperation.h"
#import "WAUnmanagedAuth.h"

@interface WAAuthViewController () <UIWebViewDelegate, WARemoteMediatorOperationDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *authorizationURL;
@property (nonatomic, strong) NSString *tokenURL;
@property (nonatomic, strong) NSString *redirectURI;
@property (nonatomic, strong) WARemoteMediatorOperation *accessTokenOperation;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

#pragma mark - PrivateHelper Methods
- (NSString *)authenticateURLString;
- (WARemoteMediatorOperation *)accessTokenForAuthCode:(NSString *)authCode;

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(UIWebView *)webView;
- (void)webViewDidFinishLoad:(UIWebView *)webView;

#pragma mark - WARemoteMediatorOperationDelegate Methods
- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didFetchAuth:(WAUnmanagedAuth *)auth;
- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didNotFetchWithError:(NSError *)error;

@end

@implementation WAAuthViewController

@synthesize scope, delegate;
@synthesize webView, clientId, clientSecret, authorizationURL, tokenURL, redirectURI, accessTokenOperation, activityIndicatorView;

- (WAAuthViewController *)initWithAuthorisationURL:(NSString *)newAuthorizationURL tokenURL:(NSString *)newTokenURL clientId:(NSString *)newClientId clientSecret:(NSString *)newClientSecret redirectURI:(NSString *)newRedirectURI
{
    if (self = [super init])
    {
        self.authorizationURL = newAuthorizationURL;
        self.tokenURL = newTokenURL;
        self.clientId = newClientId;
        self.clientSecret = newClientSecret;
        self.redirectURI = newRedirectURI;
        
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicatorView];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self authenticateURLString]]]];
}

#pragma mark - PublicHelper Methods

+ (NSString *)encodedOAuthValueForString:(NSString *)string
{
    CFStringRef originalString = (__bridge CFStringRef)string;
    CFStringRef leaveUnescaped = NULL;
    CFStringRef forceEscaped =  CFSTR("!*'();:@&=+$,/?%#[]");
    
    CFStringRef escapedString = NULL;
    
    if (string)
    {
        escapedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, originalString, leaveUnescaped, forceEscaped, kCFStringEncodingUTF8);
    }
    
    return (__bridge_transfer NSString *)escapedString;
}

- (void)setFrame:(CGRect)frame
{
    self.view.frame = frame;
    self.webView.frame = self.view.bounds;
}

- (void)stopLoading
{
    [self.webView stopLoading];
}

#pragma mark - PrivateHelper Methods

- (NSString *)authenticateURLString
{
    NSMutableString *authenticateURLString = [NSMutableString stringWithFormat:@"%@?client_id=%@&response_type=token&redirect_uri=%@", self.authorizationURL, self.clientId, self.redirectURI];
    
    if (self.scope != nil && self.scope.length > 0)
    {
        [authenticateURLString appendFormat:@"&scope=%@", self.scope];
    }
    
    return authenticateURLString;
}

- (WARemoteMediatorOperation *)accessTokenForAuthCode:(NSString *)authCode
{
    NSMutableString *postBody = [NSMutableString stringWithFormat:@"code=%@&redirect_uri=%@&client_id=%@&client_secret=%@&grant_type=authorization_code",
                                 [self.class encodedOAuthValueForString:authCode],
                                 [self.class encodedOAuthValueForString:self.redirectURI],
                                 [self.class encodedOAuthValueForString:self.clientId],
                                 [self.class encodedOAuthValueForString:self.clientSecret]];
    
    if (self.scope != nil && self.scope.length > 0)
    {
        [postBody appendFormat:@"&scope=%@", [self.class encodedOAuthValueForString:self.scope]];
    }
    
    WAAuthParser *authParser = [[WAAuthParser alloc] init];
    
    WAUrl *basketUrl = [[WAUrl alloc] init];
    basketUrl.domain = self.tokenURL;
    basketUrl.method = WAUrlRequestMethodPost;
    basketUrl.postBody = postBody;
    
    WARemoteMediatorOperation *remoteMediatorOperation = [[WARemoteMediatorOperation alloc] init];
    remoteMediatorOperation.parser = authParser;
    remoteMediatorOperation.url = basketUrl;
    
    return remoteMediatorOperation;
}

#pragma mark - UIWebViewDelegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if([request.URL.absoluteString hasPrefix:self.redirectURI])
    {
        /* Check for the Authorisation Code to be used for getting the access/refresh tokens. */
        
        if ([request.URL.absoluteString rangeOfString:@"code="].location != NSNotFound)
        {
            /* We no longer require the web view, it can be dismissed. */
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            /* Make a POST call with the newly retreived Authorization Code to get the access/refresh tokens. */
            
            self.accessTokenOperation = [self accessTokenForAuthCode:[request.URL.absoluteString componentsSeparatedByString:@"="].lastObject];
            self.accessTokenOperation.delegate = self;
            [self.accessTokenOperation fetch];
        }
        
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicatorView stopAnimating];
}

#pragma mark - WARemoteMediatorOperationDelegate Methods

- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didFetchAuth:(WAUnmanagedAuth *)auth
{
    if (auth.accessToken != nil && [auth.accessToken length] > 0 && auth.refreshToken != nil && [auth.refreshToken length] > 0)
    {
        if ([self.delegate respondsToSelector:@selector(authViewController:didAuthoriseWithAuth:)])
        {
            [self.delegate authViewController:self didAuthoriseWithAuth:auth];
        }
    }
    else
    {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:NSLocalizedString(@"WAAUTHVC.Authentication Error", nil) forKey:NSLocalizedDescriptionKey];
        [userInfo setObject:NSLocalizedString(@"WAAUTHVC.A problem occurred whilst authenticating the request.", nil) forKey:NSLocalizedRecoverySuggestionErrorKey];
        
        NSError *authError = [NSError errorWithDomain:[NSString stringWithFormat:@"%@ Error", [self class]] code:0 userInfo:userInfo];
        
        if ([self.delegate respondsToSelector:@selector(authViewController:didFailWithError:)])
        {
            [self.delegate authViewController:self didFailWithError:authError];
        }
    }
}

- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didNotFetchWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(authViewController:didFailWithError:)])
    {
        [self.delegate authViewController:self didFailWithError:error];
    }
}

@end
