#import <Foundation/Foundation.h>

@protocol WAProductInstanceProtocol, WAProductProtocol;

@interface WAProductModelHelper : NSObject

#pragma mark - ProductProtocolHelper Methods
+ (NSArray *)imageIdArrayWithImageData:(NSData *)imageData;
+ (id)jsonObjectWithDetail:(BOOL)detail andProduct:(NSObject <WAProductProtocol> *)product;
+ (BOOL)validForDeletionWithIdentifier:(NSNumber *)identifier;
+ (NSError *)validForUploadWithProduct:(NSObject <WAProductProtocol> *)product;

#pragma mark - PublicHelper Methods
+ (NSError *)errorWithDescription:(NSString *)description andRecoverySuggestion:(NSString *)recoverySuggestion;
+ (NSObject <WAProductInstanceProtocol> *)latestProductInstanceFromProductInstances:(NSSet *)productInstances;
+ (NSDate *)latestProductInstanceAddedDateWithProductInstances:(NSSet *)productInstances;
+ (NSNumber *)latestProductInstanceIdentifierWithProductInstances:(NSSet *)productInstances;

#pragma mark - PublicPrice Methods
+ (NSDecimalNumber *)latestPriceWithProductInstances:(NSSet *)productInstances;
+ (NSDecimalNumber *)latestTaxPercentageWithProductInstances:(NSSet *)productInstances;
+ (void)setLatestPriceWithProductInstances:(NSSet *)productInstances andPrice:(NSDecimalNumber *)price;
+ (void)setLatestTaxPercentageWithProductInstances:(NSSet *)productInstances andTaxPercentage:(NSDecimalNumber *)taxPercentage;

@end
