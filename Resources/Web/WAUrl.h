#import <Foundation/Foundation.h>

typedef void(^UrlCallback)(void);

typedef enum FetchType
{
    WAUrlFetchTypeUserInfo = 1,
    WAUrlFetchTypeProductComponents,
    WAUrlFetchTypeProducts,
    WAUrlFetchTypeBaskets,
    WAUrlFetchTypeCategories,
    WAUrlFetchTypeStatus,
    WAUrlFetchTypeRefreshOAuthToken,
    WAUrlFetchTypeStampitUser,
    WAUrlFetchTypeStampitReward,
    WAUrlFetchTypeStampitRedeem,
    WAUrlFetchTypePromotion,
    WAUrlFetchTypeMerchantDetails,
    WAUrlFetchTypeStoreDetails,
    WAUrlFetchTypeCloseOuts,
    WAUrlFetchTypeTransactions,
} WAUrlFetchType;

typedef enum RequestMethod
{
	WAUrlRequestMethodPost = 1,
    WAUrlRequestMethodGet,
    WAUrlRequestMethodPut,
    WAUrlRequestMethodDelete,
} WAUrlRequestMethod;

@protocol WAUrlDelegate;

@interface WAUrl : NSOperation
{
    __weak id <WAUrlDelegate> delegate;
    WAUrlFetchType type;
    WAUrlRequestMethod method;
    NSString *domain;
    NSString *postBody;
    NSURLResponse *urlResponse;
    UrlCallback callback;
    NSURLRequestCachePolicy cachingPolicy;
    
    @private
    NSTimer *timeoutTimer;
    NSTimer *receivedDataTimer;
    NSMutableDictionary *headers;
    NSMutableDictionary *parameters;
    NSMutableData *receivedData;
    NSUInteger downloadedContentLength;
    long long contentLength;
}

@property (nonatomic, weak) id <WAUrlDelegate> delegate;
@property (nonatomic) WAUrlFetchType type;
@property (nonatomic) WAUrlRequestMethod method;
@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSString *postBody;
@property (nonatomic, strong) NSURLResponse *urlResponse;
@property (nonatomic, copy) UrlCallback callback;
@property (nonatomic) NSURLRequestCachePolicy cachingPolicy;

#pragma mark - Set Methods
- (void)setHeader:(id)header forKey:(id)key;
- (void)setParameter:(id)parameter forKey:(id)key;

#pragma mark - Add Methods
- (void)addHeaders:(NSMutableDictionary *)newHeaders;
- (void)addParameters:(NSMutableDictionary *)newParameters;

#pragma mark - PublicHelper Methods
- (void)start;
- (void)restart;
- (NSString *)fetchTypeString;

#pragma mark - Class Utility Methods
+ (NSString *)encodeString:(NSString *)string;

@end

@protocol WAUrlDelegate <NSObject>

@optional
- (void)url:(WAUrl *)url didFinishLoadingData:(NSData *)data;
- (void)url:(WAUrl *)url didFailWithError:(NSError *)error;
- (void)url:(WAUrl *)url loadingWithPercentage:(int)percentage;

@end
