#import <Foundation/Foundation.h>

@protocol WAProductInstanceProtocol;

@protocol WAProductProtocol <NSObject>

@property (nonatomic, strong) NSDate *activeDate;
@property (nonatomic, strong) NSString *barcode;
@property (nonatomic, strong) NSDate *deleteDate;
@property (nonatomic, strong) NSString *details;
@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSData *imageIds;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, retain) NSDecimalNumber *price;
@property (nonatomic, retain) NSNumber *unit;
@property (nonatomic, retain) NSDecimalNumber *taxPercentage;
@property (nonatomic, strong) NSSet *categories;
@property (nonatomic, strong) NSSet *productInstances;

#pragma mark - Helper Methods
- (NSArray *)imageIdArray;
- (id)jsonObject;
- (id)jsonObjectWithDetail:(BOOL)detail;
- (NSDecimalNumber *)latestPrice;
- (NSDate *)latestProductInstanceAddedDate;
- (NSObject <WAProductInstanceProtocol> *)latestProductInstanceFromProductInstances;
- (NSNumber *)latestProductInstanceIdentifier;
- (NSDecimalNumber *)latestTaxPercentage;
- (void)setLatestPrice:(NSDecimalNumber *)latestPrice;
- (void)setLatestTaxPercentage:(NSDecimalNumber *)latestTaxPercentage;
- (BOOL)validForDeletion;
- (NSError *)validForUpload;

@end
