#import "WARemoteMediatorOperation.h"
#import "WAUrl.h"
#import "WAParser.h"
#import "WAUnmanagedMessage.h"
#import "WAUserMediator.h"
#import "WARemoteUserMediator.h"
#import "WAUnmanagedAuth.h"
#import "WAApplicationViewController.h"

@interface WARemoteMediatorOperation () <WAUrlDelegate, WAParserDelegate, WARemoteMediatorOperationDelegate>

@property (nonatomic, strong) WARemoteMediatorOperation *refreshAccessTokenOperation;

#pragma mark - WAUrlDelegate Methods
- (void) url:(WAUrl *)url didFinishLoadingData:(NSData *)data;
- (void) url:(WAUrl *)url didFailWithError:(NSError *)error;
- (void) url:(WAUrl *)url loadingWithPercentage:(int)percentage;

@end

@implementation WARemoteMediatorOperation

@synthesize delegate, url, parser, object, tag;
@synthesize refreshAccessTokenOperation;

#pragma mark - PublicHelper Methods

- (void)fetch
{
    self.url.delegate = self;
    self.parser.delegate = self;
    
    [self.url start];
}

#pragma mark - WAUrlDelegate Methods

- (void)url:(WAUrl *)url didFinishLoadingData:(NSData *)data
{
    [self.parser parseErrorsWithData:data];
}

- (void)url:(WAUrl *)newUrl didFailWithError:(NSError *)error
{
    [[WALogView sharedLogView] addLog:[[WALog alloc] initWithTitle:[NSString stringWithFormat:@"%@ FAIL", [self.url fetchTypeString]] description:[NSString stringWithFormat:@"MAJOR REMOTE MEDIATOR FAIL\t:%@ methods = %i, domain = %@, postbody = %@", error, newUrl.method, newUrl.domain, newUrl.postBody] type:WALogTypeDeveloper status:WALogStatusDead location:WALogLocationLocal]];
    
    if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didNotFetchWithError:)])
    {
        [self.delegate remoteMediatorOperation:self didNotFetchWithError:error];
    }
}

- (void)url:(WAUrl *)url loadingWithPercentage:(int)percentage
{
    
}

#pragma mark - ParserDelegate Methods

- (void)parser:(WAParser *)parser didParseErrors:(NSDictionary *)messageDictionary warnings:(NSDictionary *)warnings withData:(NSData *)data
{
    if (([messageDictionary objectForKey:[NSNumber numberWithInt:907]] != nil || [messageDictionary objectForKey:[NSNumber numberWithInt:908]] != nil))
    {
        //Invalid(907) or Expired Token(908)
        
        if (self.refreshAccessTokenOperation == nil)
        {
            self.refreshAccessTokenOperation = [[WARemoteUserMediator sharedRemoteUserMediator] refreshAccessTokenForCurrentUser];
            
            if (self.refreshAccessTokenOperation != nil)
            {
                self.refreshAccessTokenOperation.delegate = self;
                [self.refreshAccessTokenOperation fetch];
            }
            else
            {
                NSError *error = [NSError errorWithDomain:@"Something went wrong." code:0 userInfo:nil];
                
                [[WALogView sharedLogView] addLog:[[WALog alloc] initWithTitle:[NSString stringWithFormat:@"%@ FAIL", [self.url fetchTypeString]] description:[error description] type:WALogTypeDeveloper status:WALogStatusDead location:WALogLocationLocal]];
                
                if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didNotFetchWithError:)])
                {
                    [self.delegate remoteMediatorOperation:self didNotFetchWithError:error];
                }
            }
        }
        else
        {
            NSError *error = [NSError errorWithDomain:@"Could not use access token" code:0 userInfo:nil];
            
            [[WALogView sharedLogView] addLog:[[WALog alloc] initWithTitle:[NSString stringWithFormat:@"%@ FAIL", [self.url fetchTypeString]] description:[error description] type:WALogTypeDeveloper status:WALogStatusDead location:WALogLocationLocal]];
            
            if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didNotFetchWithError:)])
            {
                [self.delegate remoteMediatorOperation:self didNotFetchWithError:error];
            }
        }
    }
    else if ([messageDictionary count] > 0)
    {
        NSError *error = [NSError errorWithDomain:@"Something went wrong." code:0 userInfo:messageDictionary];
        
        [[WALogView sharedLogView] addLog:[[WALog alloc] initWithTitle:[NSString stringWithFormat:@"%@ FAIL", [self.url fetchTypeString]] description:[error description] type:WALogTypeDeveloper status:WALogStatusDead location:WALogLocationLocal]];
        
        if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didNotFetchWithError:)])
        {
            [self.delegate remoteMediatorOperation:self didNotFetchWithError:error];
        }
    }
    else
    {
        [self.parser parseData:data withWarnings:warnings];
    }
}

- (void)parser:(WAParser *)parser didParseAuth:(WAUnmanagedAuth *)auth
{
    if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didFetchAuth:)])
    {
        [self.delegate remoteMediatorOperation:self didFetchAuth:auth];
    }
}

- (void)parser:(WAParser *)parser didParseBaskets:(NSDictionary *)baskets
{
    if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didFetchBaskets:)])
    {
        [self.delegate remoteMediatorOperation:self didFetchBaskets:baskets];
    }
}

- (void)parser:(WAParser *)parser didParseCategories:(NSDictionary *)categories
{
    if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didFetchCategories:)])
    {
        [self.delegate remoteMediatorOperation:self didFetchCategories:categories];
    }
}

- (void)parser:(WAParser *)parser didParseCloseOuts:(NSDictionary *)closeOuts
{
    if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didFetchCloseOuts:)])
    {
        [self.delegate remoteMediatorOperation:self didFetchCloseOuts:closeOuts];
    }
}

- (void)parser:(WAParser *)parser didParseData:(NSData *)data
{
    if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didFetchWithData:)])
    {
        [self.delegate remoteMediatorOperation:self didFetchWithData:data];
    }
}

- (void)parser:(WAParser *)parser didParseMerchant:(WAUnmanagedMerchant *)unmanagedMerchant
{
    if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didFetchMerchant:)])
    {
        [self.delegate remoteMediatorOperation:self didFetchMerchant:unmanagedMerchant];
    }
}

- (void)parser:(WAParser *)parser didParseProducts:(NSDictionary *)products
{
    if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didRefreshAllProducts:)])
    {
        [self.delegate remoteMediatorOperation:self didRefreshAllProducts:products];
    }
}

- (void)parser:(WAParser *)parser didParseProductComponents:(NSDictionary *)productComponents
{
    if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didRefreshAllProductComponents:)])
    {
        [self.delegate remoteMediatorOperation:self didRefreshAllProductComponents:productComponents];
    }
}

- (void)parser:(WAParser *)parser didParseStampitRewards:(NSDictionary *)rewards
{
    if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didParseStampitRewards:)])
    {
        [self.delegate remoteMediatorOperation:self didParseStampitRewards:rewards];
    }
}

- (void)parser:(WAParser *)parser didParseStampitRewardRedemption:(WAUnmanagedRewardRedemption *)redemption
{
    if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didParseStampitRewardRedemption:)])
    {
        [self.delegate remoteMediatorOperation:self didParseStampitRewardRedemption:redemption];
    }
}

- (void)parser:(WAParser *)parser didParsePromotions:(NSDictionary *)promotions
{
    if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didFetchPromotions:)])
    {
        [self.delegate remoteMediatorOperation:self didFetchPromotions:promotions];
    }
}

- (void)parser:(WAParser *)parser didParseStatus:(NSArray *)messageArray
{
    if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didFetchStatus:)])
    {
        [self.delegate remoteMediatorOperation:self didFetchStatus:messageArray];
    }
}

- (void)parser:(WAParser *)parser didParseStores:(NSArray *)unmanagedStores
{
    if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didFetchStores:)])
    {
        [self.delegate remoteMediatorOperation:self didFetchStores:unmanagedStores];
    }
}

- (void)parser:(WAParser *)parser didParseTransactions:(NSDictionary *)transactions
{
    if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didFetchTransactions:)])
    {
        [self.delegate remoteMediatorOperation:self didFetchTransactions:transactions];
    }
}

- (void)parser:(WAParser *)parser didParseUser:(NSArray *)userArray
{
    if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didFetchUser:)])
    {
        [self.delegate remoteMediatorOperation:self didFetchUser:userArray];
    }
}

- (void)parser:(WAParser *)parser didNotParseWithError:(NSError *)error
{
    [[WALogView sharedLogView] addLog:[[WALog alloc] initWithTitle:[NSString stringWithFormat:@"%@ FAIL", [self.url fetchTypeString]] description:[error description] type:WALogTypeDeveloper status:WALogStatusDead location:WALogLocationRemote]];
    
    if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didNotFetchWithError:)])
    {
        [self.delegate remoteMediatorOperation:self didNotFetchWithError:error];
    }
}

#pragma mark - WARemoteMediatorOperationDelegate Methods

- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didFetchAuth:(WAUnmanagedAuth *)auth
{
    if (auth.accessToken != nil && [auth.accessToken length] > 0)
    {
        [[WALogView sharedLogView] addLog:[[WALog alloc] initWithTitle:[NSString stringWithFormat:@"%@ HAS TOKEN", [self.url fetchTypeString]] description:@"" type:WALogTypeDeveloper status:WALogStatusRunning location:WALogLocationRemote]];
        
        [self.url setHeader:[NSString stringWithFormat:@"OAuth %@", auth.accessToken] forKey:@"Authorization"];
        
        [[WAUserMediator sharedUserMediator] setAccessToken:auth.accessToken forUser:[[WAUserMediator sharedUserMediator] synchronousCurrentUser]];
        
        [self.url start];
    }
    else
    {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:NSLocalizedString(@"WARMO.Authentication Error", nil) forKey:NSLocalizedDescriptionKey];
        [userInfo setObject:NSLocalizedString(@"WARMO.A problem occurred whilst authenticating the request.", nil) forKey:NSLocalizedRecoverySuggestionErrorKey];
        
        NSError *authError = [NSError errorWithDomain:[NSString stringWithFormat:@"%@ Error", [self class]] code:0 userInfo:userInfo];
        
        if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didNotFetchWithError:)])
        {
            [self.delegate remoteMediatorOperation:self didNotFetchWithError:authError];
        }
    }
}

- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didNotFetchWithError:(NSError *)error
{
    [[WALogView sharedLogView] addLog:[[WALog alloc] initWithTitle:[NSString stringWithFormat:@"%@ FAIL", [self.url fetchTypeString]] description:[error description] type:WALogTypeDeveloper status:WALogStatusDead location:WALogLocationRemote]];
    
    if ([self.delegate respondsToSelector:@selector(remoteMediatorOperation:didNotFetchWithError:)])
    {
        [self.delegate remoteMediatorOperation:self didNotFetchWithError:error];
    }
}

@end
