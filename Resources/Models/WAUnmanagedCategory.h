#import <Foundation/Foundation.h>
#import "WACategoryProtocol.h"
#import "WANodeProtocol.h"

@interface WAUnmanagedCategory : NSObject <WACategoryProtocol, WANodeProtocol>
{
    NSNumber *identifier;
    NSString *title;
    NSDate *deleteDate;
    NSDate *activeDate;
    NSSet *products;
    WAUnmanagedCategory *parentCategory;
    NSSet *subCategories;
    NSNumber *parentIdentifier;
    NSObject <WANodeProtocol> *parentNode;
    NSMutableArray *children;
}

@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *deleteDate;
@property (nonatomic, strong) NSDate *activeDate;
@property (nonatomic, strong) NSSet *products;
@property (nonatomic, strong) WAUnmanagedCategory *parentCategory;
@property (nonatomic, strong) NSSet *subCategories;
@property (nonatomic, strong) NSNumber *parentIdentifier;
@property (nonatomic, strong) NSObject <WANodeProtocol> *parentNode;
@property (nonatomic, strong) NSMutableArray *children;

@end
