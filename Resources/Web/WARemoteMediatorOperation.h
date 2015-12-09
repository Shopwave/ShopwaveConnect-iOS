#import <Foundation/Foundation.h>

@protocol WARemoteMediatorOperationDelegate;

@class WAUrl, WAParser, WAUnmanagedAuth, WAUnmanagedMerchant, WAUnmanagedRewardRedemption;

@interface WARemoteMediatorOperation : NSObject
{
    __weak id <WARemoteMediatorOperationDelegate> delegate;
    WAUrl *url;
    WAParser *parser;
    NSObject *object;
    int tag;
    
    @private
    WARemoteMediatorOperation *refreshAccessTokenOperation;
}

@property (nonatomic, weak) id <WARemoteMediatorOperationDelegate> delegate;
@property (nonatomic, strong) WAUrl *url;
@property (nonatomic, strong) WAParser *parser;
@property (nonatomic, strong) NSObject *object;
@property (nonatomic) int tag;

#pragma mark - PublicHelper Methods
- (void)fetch;

@end

@protocol WARemoteMediatorOperationDelegate <NSObject>

@optional

#pragma mark - App Methods
- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didFetchStatus:(NSArray *)messages;

#pragma mark - Basket Methods
- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didFetchBaskets:(NSDictionary *)baskets;

#pragma mark - Category Methods
- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didFetchCategories:(NSDictionary *)categories;

#pragma mark - CloseOut Methods
- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didFetchCloseOuts:(NSDictionary *)closeOuts;

#pragma mark - General Methods
- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didNotFetchWithError:(NSError *)error;
- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didFetchWithData:(NSData *)data;

#pragma mark - Merchant Methods
- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didFetchMerchant:(WAUnmanagedMerchant *)unmanagedMerchant;

#pragma mark - Product Methods
- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didRefreshAllProducts:(NSDictionary *)products;

#pragma mark - Product Component Methods
- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didRefreshAllProductComponents:(NSDictionary *)productComponents;

#pragma mark - Reward Methods
- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didParseStampitRewards:(NSDictionary *)rewards;
- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didParseStampitRewardRedemption:(WAUnmanagedRewardRedemption *)redemption;

#pragma mark - Promotion Methods
- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didFetchPromotions:(NSDictionary *)promotions;

#pragma mark - Store Methods
- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didFetchStores:(NSArray *)unmanagedStores;

#pragma mark - Transaction Methods
- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didFetchTransactions:(NSDictionary *)transactions;

#pragma mark - User Methods
- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didFetchUser:(NSArray *)user;
- (void)remoteMediatorOperation:(WARemoteMediatorOperation *)remoteMediatorOperation didFetchAuth:(WAUnmanagedAuth *)auth;

@end
