#import <Foundation/Foundation.h>

@protocol WAParserDelegate;

@class WAUnmanagedUser, WAUnmanagedAuth, WAUnmanagedMerchant, WAUnmanagedRewardRedemption;

@interface WAParser : NSObject
{
    __weak id <WAParserDelegate> delegate;
}

@property (nonatomic, weak) id <WAParserDelegate> delegate;

#pragma mark - PublicHelper Methods
- (void)parseData:(NSData *)data withWarnings:(NSDictionary *)warnings;
- (void)parseErrorsWithData:(NSData *)data;

- (void)dispatchErrorWithTitle:(NSString *)title andMessage:(NSString *)message;

- (NSString *)parseStringWithObject:(NSObject *)newObject;
- (NSNumber *)parseNumberWithObject:(NSObject *)newObject;
- (BOOL)parseBoolWithObject:(NSObject *)newObject;
- (int)parseIntWithObject:(NSObject *)newObject;
- (float)parseFloatWithObject:(NSObject *)newObject;

@end

@protocol WAParserDelegate <NSObject>

@optional

#pragma mark - Auth Methods
- (void)parser:(WAParser *)parser didParseAuth:(WAUnmanagedAuth *)auth;

#pragma mark - Basket Methods
- (void)parser:(WAParser *)parser didParseBaskets:(NSDictionary *)baskets;

#pragma mark - Category Methods
- (void)parser:(WAParser *)parser didParseCategories:(NSDictionary *)categories;

#pragma mark - CloseOut Methods
- (void)parser:(WAParser *)parser didParseCloseOuts:(NSDictionary *)closeOuts;

#pragma mark - Error Methods
- (void)parser:(WAParser *)parser didParseErrors:(NSDictionary *)messageDictionary warnings:(NSDictionary *)warnings withData:(NSData *)data;

#pragma mark - General Methods
- (void)parser:(WAParser *)parser didNotParseWithError:(NSError *)error;
- (void)parser:(WAParser *)parser didParseData:(NSData *)data;

#pragma mark - Merchant Methods
- (void)parser:(WAParser *)parser didParseMerchant:(WAUnmanagedMerchant *)unmanagedMerchant;

#pragma mark - Message Methods
- (void)parser:(WAParser *)parser didParseStatus:(NSString *)status;

#pragma mark - Product Methods
- (void)parser:(WAParser *)parser didParseProducts:(NSDictionary *)products;

#pragma mark - Product Component Methods
- (void)parser:(WAParser *)parser didParseProductComponents:(NSDictionary *)productComponents;

#pragma mark - Promotion Methods
- (void)parser:(WAParser *)parser didParsePromotions:(NSDictionary *)promotions;

#pragma mark - Stampit Methods
- (void)parser:(WAParser *)parser didParseStampitRewards:(NSDictionary *)rewards;
- (void)parser:(WAParser *)parser didParseStampitRewardRedemption:(WAUnmanagedRewardRedemption *)redemption;

#pragma mark - Store Methods
- (void)parser:(WAParser *)parser didParseStores:(NSArray *)unmanagedStores;

#pragma mark - Transaction Methods
- (void)parser:(WAParser *)parser didParseTransactions:(NSDictionary *)transactions;

#pragma mark - User Methods
- (void)parser:(WAParser *)parser didParseUser:(NSArray *)userArray;

@end
