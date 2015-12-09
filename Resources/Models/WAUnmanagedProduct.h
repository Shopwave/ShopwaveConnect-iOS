#import <Foundation/Foundation.h>
#import "WAProductProtocol.h"

@class WAUnmanagedProductInstance;

@interface WAUnmanagedProduct : NSObject <WAProductProtocol>
{
    NSDate *activeDate;
    NSString *barcode;
    NSDate *deleteDate;
    NSString *details;
    NSNumber *identifier;
    NSData *imageIds;
    NSString *name;
    NSDecimalNumber *price;
    NSNumber *unit;
    NSDecimalNumber *taxPercentage;
    NSSet *basketProducts;
    NSSet *categories;
    NSSet *productInstances;
}

@property (nonatomic, strong) NSDate *activeDate;
@property (nonatomic, strong) NSString *barcode;
@property (nonatomic, strong) NSDate *deleteDate;
@property (nonatomic, strong) NSString *details;
@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSData *imageIds;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDecimalNumber *price;
@property (nonatomic, strong) NSNumber *unit;
@property (nonatomic, strong) NSDecimalNumber *taxPercentage;
@property (nonatomic, strong) NSSet *basketProducts;
@property (nonatomic, strong) NSSet *categories;
@property (nonatomic, strong) NSSet *productInstances;

@end
