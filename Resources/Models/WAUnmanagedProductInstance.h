#import <Foundation/Foundation.h>
#import "WAProductInstanceProtocol.h"
#import "WAUnmanagedProduct.h"
#import "WAUnmanagedProductComponent.h"

@interface WAUnmanagedProductInstance : NSObject <WAProductInstanceProtocol>
{
    NSNumber *identifier;
    NSString *name;
    NSDecimalNumber *price;
    NSDecimalNumber *quantity;
    NSDecimalNumber *size;
    NSDecimalNumber *taxPercentage;
    NSDate *addedDate;
    NSSet *basketProducts;
    WAUnmanagedProduct *product;
}

@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDecimalNumber *price;
@property (nonatomic, strong) NSDecimalNumber *quantity;
@property (nonatomic, strong) NSDecimalNumber *size;
@property (nonatomic, strong) NSDecimalNumber *taxPercentage;
@property (nonatomic, strong) NSDate *addedDate;
@property (nonatomic, strong) NSSet *basketProducts;
@property (nonatomic, strong) WAUnmanagedProduct *product;

@end
