#import <Foundation/Foundation.h>

typedef enum WAUnmanagedAuthTokenType
{
    WAUnmanagedAuthTokenTypeNone = 1,
    WAUnmanagedAuthTokenTypeBearer,
} WAUnmanagedAuthTokenType;

@interface WAUnmanagedAuth : NSObject
{
    NSString *accessToken;
    NSString *refreshToken;
    WAUnmanagedAuthTokenType tokenType;
    int expiresIn;
}

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic) WAUnmanagedAuthTokenType tokenType;
@property (nonatomic) int expiresIn;

@end
