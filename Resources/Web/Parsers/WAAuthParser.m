#import "WAAuthParser.h"
#import "WAUnmanagedAuth.h"

@implementation WAAuthParser

#pragma mark - PublicHelper Methods

- (void)parseData:(NSData *)data withWarnings:(NSDictionary *)warnings
{
    [super parseData:data withWarnings:warnings];
    
    NSError* error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (error == nil && [NSJSONSerialization isValidJSONObject:json])
    {
        WAUnmanagedAuth *auth = [[WAUnmanagedAuth alloc] init];
        auth.accessToken = [self parseStringWithObject:[json objectForKey:@"access_token"]];
        auth.refreshToken = [self parseStringWithObject:[json objectForKey:@"refresh_token"]];
        auth.tokenType = [[self parseStringWithObject:[json objectForKey:@"token_type"]] isEqualToString:@"Bearer"] ? WAUnmanagedAuthTokenTypeBearer : WAUnmanagedAuthTokenTypeNone;
        auth.expiresIn = [self parseIntWithObject:[json objectForKey:@"expires_in"]];
        
        if ([self.delegate respondsToSelector:@selector(parser:didParseAuth:)])
        {
            [self.delegate parser:self didParseAuth:auth];
        }
    }
    else
    {
        [self dispatchErrorWithTitle:NSLocalizedString(@"WAAuthP.No Authentication Found", nil)
                          andMessage:NSLocalizedString(@"WAAuthP.Please try again.", nil)];
    }
}

@end
