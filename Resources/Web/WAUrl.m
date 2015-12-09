#import "WAUrl.h"

@interface WAUrl () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableDictionary *headers;
@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, strong) NSTimer *timeoutTimer;
@property (nonatomic, strong) NSTimer *receivedDataTimer;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic) NSUInteger downloadedContentLength;
@property (nonatomic) long long contentLength;

#pragma mark - Get Methods
- (id)headerForKey:(id)aKey;
- (id)parameterForKey:(id)aKey;

#pragma mark - PrivateHelper Methods
- (NSString *)parameterStringValue;
- (NSString *)stringValue;
- (NSURL *) urlValue;
- (NSString *)requestMethodString;
- (NSString *)headerString;
- (void)fetch;
- (void)main;
- (void)makeAsynchronousRequest:(NSMutableURLRequest *)request;
- (void)startTimeoutTimer:(NSURLConnection *)connection;
- (void)startReceivedDataTimeoutTimer:(NSURLConnection *)connection;
- (void)invalidateTimers;
- (void)invalidateReceivedDataTimer;

#pragma mark - NSTimer, NSURLConnectionDelegate & NSURLConnectionDataDelegate Methods
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
-(void)connectionDidFinishLoading:(NSURLConnection *)connection;
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
-(void)onTimeout:(NSTimer *)timer;

@end

@implementation WAUrl

@synthesize delegate, type, method, domain, postBody, urlResponse, callback, cachingPolicy;
@synthesize timeoutTimer, receivedDataTimer, headers, contentLength, receivedData, downloadedContentLength, parameters;

static NSOperationQueue *queue;

#pragma mark - NSObject Methods

- (id)init
{
    self = [super init];
    if (self)
    {
        self.cachingPolicy = -1;
    }
    return self;
}

- (BOOL)isEqual:(id)newObject
{
    return [newObject isKindOfClass:[WAUrl class]] && (self == newObject || ([[self stringValue] isEqual:[((WAUrl *)newObject) stringValue]] && [[self headerString] isEqual:[((WAUrl *)newObject) headerString]]));
}

- (NSString *)description
{
    return [self stringValue];
}

#pragma mark - Set Methods

- (void)setHeader:(id)header forKey:(id)key
{
    if (self.headers == nil)
    {
        self.headers = [[NSMutableDictionary alloc] init];
    }
    
    [self.headers setObject:header forKey:key];
}

- (void)setParameter:(id)parameter forKey:(id)key
{
    if (self.parameters == nil)
    {
        self.parameters = [[NSMutableDictionary alloc] init];
    }
    
    [self.parameters setObject:parameter forKey:key];
}

#pragma mark - Add Methods

- (void)addHeaders:(NSMutableDictionary *)newHeaders
{
    if (self.headers == nil)
    {
        self.headers = [[NSMutableDictionary alloc] init];
    }
    
    [self.headers addEntriesFromDictionary:newHeaders];
}

- (void)addParameters:(NSMutableDictionary *)newParameters
{
    if (self.parameters == nil)
    {
        self.parameters = [[NSMutableDictionary alloc] init];
    }
    
    [self.parameters addEntriesFromDictionary:newParameters];
}

#pragma mark - Get Methods

- (id)headerForKey:(id)aKey
{
    return [self.headers objectForKey:aKey];
}

- (id)parameterForKey:(id)aKey
{
    return [self.parameters objectForKey:aKey];
}

#pragma mark - PublicHelper Methods

- (void)start
{
    [self performSelectorInBackground:@selector(fetch) withObject:nil];
}

- (void)restart
{
    [self start];
}

- (void)fetch
{
    if (queue == nil)
    {
        queue = [[NSOperationQueue alloc] init];
    }
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(main) object:nil];
    
    [queue addOperation:operation];
}

#pragma mark - PrivateHelper Methods

- (NSString *)parameterStringValue
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    /* PREPARE PARAMS */
    
    for (NSString *key in self.parameters.allKeys)
    {
        if ([self.parameters objectForKey:key] != nil && [[self.parameters objectForKey:key] length] > 0)
        {
            [string appendFormat:@"%@%@%@%@", key, @"=", [self.parameters objectForKey:key], @"&"];
        }
    }
    
    /* REMOVE EXTRA CHARS IF NEEDED */
    
    if ([string length] > 0)
    {
        return [string substringToIndex:[string length] - 1];
    }
    
    return [NSString stringWithString:string];
}

- (NSString *)stringValue
{
    NSMutableString *string = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@%@", self.domain, [self fetchTypeString] != nil ? [self fetchTypeString] : @""]];
    NSString *parameterString = [self parameterStringValue];
    
    if (parameterString != nil && parameterString.length > 0)
    {
        [string appendString:[NSString stringWithFormat:@"%@%@", @"?", parameterString]];
    }
    
    return [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSURL *)urlValue
{
    return [NSURL URLWithString:[self stringValue]];
}

- (NSString *)fetchTypeString
{
	switch (self.type)
	{
        case WAUrlFetchTypeUserInfo:
            return @"user/";
		case WAUrlFetchTypeProducts:
			return @"product/";
        case WAUrlFetchTypeProductComponents:
            return @"product/component/";
        case WAUrlFetchTypeBaskets:
            return @"basket/";
        case WAUrlFetchTypeCategories:
            return @"category/";
        case WAUrlFetchTypeStatus:
            return @"status/";
        case WAUrlFetchTypeRefreshOAuthToken:
            return @"oauth/token/";
        case WAUrlFetchTypeStampitUser:
            return @"customerCardLogin.json";
        case WAUrlFetchTypeStampitReward:
            return @"merchantRewards.json";
        case WAUrlFetchTypeStampitRedeem:
            return @"customerRedeemRewards.json";
        case WAUrlFetchTypePromotion:
            return @"promotion/";
        case WAUrlFetchTypeMerchantDetails:
            return @"merchant/";
        case WAUrlFetchTypeStoreDetails:
            return @"store";
        case WAUrlFetchTypeCloseOuts:
            return @"log";
        case WAUrlFetchTypeTransactions:
            return @"transaction/";
		default:
			return nil;
	}
}

- (NSString *)requestMethodString
{
	switch (self.method)
	{
        case WAUrlRequestMethodPost:
            return @"POST";
        case WAUrlRequestMethodPut:
            return @"PUT";
        case WAUrlRequestMethodDelete:
            return @"DELETE";
        default:
            return @"GET";
	}
}

- (NSString *)headerString
{
    NSString *headerString = @"";
    
    for (NSString *key in self.headers.allKeys)
    {
        if ([self.headers objectForKey:key] != nil && ![[self.headers objectForKey:key] isEqual:@""])
        {
            headerString = [headerString stringByAppendingFormat:@"%@: %@&", key, [self.headers objectForKey:key]];
        }
    }
    
    if([headerString length] > 0)
    {
        headerString = [headerString substringToIndex:[headerString length] - 1];
    }
    
    return headerString;
}

- (void)main
{
    if (![self isCancelled])
    {
        @autoreleasepool
        {
            [[WALogView sharedLogView] addLog:[[WALog alloc] initWithTitle:[NSString stringWithFormat:@"%@ START", [[self stringValue] substringFromIndex:[[self stringValue] length] - MIN([[self stringValue] length], 20)]] description:[NSString stringWithFormat:@"REQ(%@)\t: %@ HEAD\t: %@",[self requestMethodString], [self stringValue], [self headerString]] type:WALogTypeDeveloper status:WALogStatusWaiting location:WALogLocationRemote]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self urlValue]];
            request.cachePolicy = self.cachingPolicy;
            [request setHTTPMethod: [self requestMethodString]];
            
            if(self.headers != nil && self.headers.count > 0)
            {
                for (NSString *key in self.headers.allKeys)
                {
                    if ([self.headers objectForKey:key] != nil && ![[self.headers objectForKey:key] isEqual:@""])
                    {
                        [request setValue:[self.headers objectForKey:key] forHTTPHeaderField:key];
                    }
                }
                
                [[WALogView sharedLogView] addLog:[[WALog alloc] initWithTitle:[NSString stringWithFormat:@"%@ HEADERS ADDED", [[self stringValue] substringFromIndex:[[self stringValue] length] - MIN([[self stringValue] length], 20)]] description:[NSString stringWithFormat:@"HEADERS: %@", [self headerString]] type:WALogTypeDeveloper status:WALogStatusWaiting location:WALogLocationRemote]];
            }
            
            if(self.method != WAUrlRequestMethodGet && self.postBody != nil && [self.postBody length] > 0)
            {
                [request setHTTPBody:[NSData dataWithData:[self.postBody dataUsingEncoding:NSUTF8StringEncoding]]];
                
                [[WALogView sharedLogView] addLog:[[WALog alloc] initWithTitle:[NSString stringWithFormat:@"%@ BODY ADDED", [[self stringValue] substringFromIndex:[[self stringValue] length] - MIN([[self stringValue] length], 20)]] description:[NSString stringWithFormat:@"BODY: %@", self.postBody] type:WALogTypeDeveloper status:WALogStatusWaiting location:WALogLocationRemote]];
            }
            
            [self makeAsynchronousRequest:request];
        }
    }
}

- (void)makeAsynchronousRequest:(NSMutableURLRequest *)request
{
    [self invalidateTimers];
    
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    [connection start];

    [self startTimeoutTimer:connection];
    [self startReceivedDataTimeoutTimer:connection];
    
    [runLoop run];
}

- (void)startTimeoutTimer:(NSURLConnection *)connection
{
   self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(onTimeout:) userInfo:connection repeats:NO];
}

- (void)startReceivedDataTimeoutTimer:(NSURLConnection *)connection
{
    self.receivedDataTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(onTimeout:) userInfo:connection repeats:NO];
}

- (void)invalidateTimers
{
    [[WALogView sharedLogView] addLog:[[WALog alloc] initWithTitle:[NSString stringWithFormat:@"%@ DONE", [self fetchTypeString]] description:@"invalidate timers" type:WALogTypeDeveloper status:WALogStatusRunning location:WALogLocationRemote]];
    
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
    
    [self.receivedDataTimer invalidate];
    self.receivedDataTimer = nil;
}

- (void)invalidateReceivedDataTimer
{
    [self.receivedDataTimer invalidate];
    self.receivedDataTimer = nil;
}

#pragma mark - NSTimer, NSURLConnectionDelegate & NSURLConnectionDataDelegate Methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.urlResponse = response;
    
    if (![self isCancelled])
    {
        self.receivedData = [[NSMutableData alloc] init];
        
        self.contentLength = [response expectedContentLength];
        
        self.downloadedContentLength = 0;
        
        [self invalidateReceivedDataTimer];
        [self startReceivedDataTimeoutTimer:connection];
    }
    else
    {
        [connection cancel];
        
        [self invalidateTimers];
        
        CFRunLoopStop(CFRunLoopGetCurrent());
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (![self isCancelled])
    {
        [self.receivedData appendData:data];
        
        self.downloadedContentLength += [data length];
        
        int percentage = MAX(0, ((double)downloadedContentLength/contentLength)*100);
        
        if([self.delegate respondsToSelector:@selector(url:loadingWithPercentage:)])
        {
            [self.delegate url:self loadingWithPercentage:percentage];
        }
        
        [self invalidateReceivedDataTimer];
        [self startReceivedDataTimeoutTimer:connection];
    }
    else
    {
        [connection cancel];
        
        [self invalidateTimers];
        
        CFRunLoopStop(CFRunLoopGetCurrent());
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[WALogView sharedLogView] addLog:[[WALog alloc] initWithTitle:[NSString stringWithFormat:@"%@ DONE", [[self stringValue] substringFromIndex:[[self stringValue] length] - MIN([[self stringValue] length], 20)]] description:[NSString stringWithFormat:@"RESPONSE\t: %@", [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding]] type:WALogTypeDeveloper status:WALogStatusRunning location:WALogLocationRemote]];
    
    connection = nil;
    
    [self invalidateTimers];
    
    if ([self.delegate respondsToSelector:@selector(url:didFinishLoadingData:)])
    {
        [self.delegate url:self didFinishLoadingData:self.receivedData];
    }
    
    // Stops connection from being active in the background
    CFRunLoopStop(CFRunLoopGetCurrent());
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[WALogView sharedLogView] addLog:[[WALog alloc] initWithTitle:[NSString stringWithFormat:@"%@ FAIL", [[self stringValue] substringFromIndex:[[self stringValue] length] - MIN([[self stringValue] length], 20)]] description:[NSString stringWithFormat:@"FAILED URL:\t %@ WITH ERROR:\t %@", [self stringValue], error] type:WALogTypeDeveloper status:WALogStatusDead location:WALogLocationRemote]];

    connection = nil;
    
    [self invalidateTimers];
    
    if([self.delegate respondsToSelector:@selector(url:didFailWithError:)])
    {
        [self.delegate url:self didFailWithError:error];
    }
    
    CFRunLoopStop(CFRunLoopGetCurrent());
}

-(void)onTimeout:(NSTimer *)timer
{
    [[WALogView sharedLogView] addLog:[[WALog alloc] initWithTitle:[NSString stringWithFormat:@"%@ TIMEOUT", [[self stringValue] substringFromIndex:[[self stringValue] length] - MIN([[self stringValue] length], 20)]] description:[NSString stringWithFormat:@"REQ(%@) TIMEOUT\t: %@ HEAD\t: %@",[self requestMethodString], [self stringValue], [self headerString]] type:WALogTypeDeveloper status:WALogStatusDead location:WALogLocationRemote]];
    
    if (timer != nil && [timer.userInfo isKindOfClass:[NSURLConnection class]])
    {
        [((NSURLConnection *)timer.userInfo) cancel];
    }
    
    [self invalidateTimers];

    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(url:didFailWithError:)])
    {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:NSLocalizedString(@"WAU.No Internet Connection", nil) forKey:NSLocalizedDescriptionKey];
        [userInfo setObject:NSLocalizedString(@"WAU.Please check your internet connection.", nil) forKey:NSLocalizedRecoverySuggestionErrorKey];
        
        NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@ Error", [self class]] code:0 userInfo:userInfo];
        
        [self.delegate url:self didFailWithError:error];
    }
    
    CFRunLoopStop(CFRunLoopGetCurrent());
}

#pragma mark - Class Utility Methods

+ (NSString *)encodeString:(NSString *)string
{
    NSMutableCharacterSet *characterSet;
    characterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [characterSet removeCharactersInRange:NSMakeRange('&', 1)]; // %26
    [characterSet removeCharactersInRange:NSMakeRange('=', 1)]; // %3D
    [characterSet removeCharactersInRange:NSMakeRange('?', 1)]; // %3F
    [characterSet removeCharactersInRange:NSMakeRange('+', 1)]; // %2B
    
    return string != nil ? [NSString stringWithString:[string stringByAddingPercentEncodingWithAllowedCharacters:characterSet]] : nil;
}

+ (NSString *)decodeString:(NSString *)string
{
    return [NSString stringWithString:[string stringByRemovingPercentEncoding]];
}

+ (NSString *)jsonEncodeString:(NSString *)string
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:[NSArray arrayWithObject: string] options:0 error:nil];
    
	NSString *encodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	encodedString = [encodedString substringWithRange:NSMakeRange(2, [encodedString length] - 4)];
    
	return encodedString;
}

@end
