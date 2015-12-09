#import <Foundation/Foundation.h>

@protocol WAProductProtocol, WAProductComponentProtocol;

@protocol WAProductInstanceProtocol <NSObject>

@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDecimalNumber *price;
@property (nonatomic, strong) NSDecimalNumber *quantity;
@property (nonatomic, strong) NSDecimalNumber *size;
@property (nonatomic, strong) NSDecimalNumber *taxPercentage;
@property (nonatomic, strong) NSDate *addedDate;
@property (nonatomic, strong) NSObject <WAProductProtocol> *product;

- (id)jsonObject;
- (id)jsonObjectWithDetail:(BOOL)detail;
- (BOOL)isSizeBased;

@end
