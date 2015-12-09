#import "WAUnmanagedProductInstance.h"
#import "WAProductInstanceModelHelper.h"

@implementation WAUnmanagedProductInstance

@synthesize identifier, name, price, quantity, size, taxPercentage, addedDate, basketProducts, product;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.price = [aDecoder decodeObjectForKey:@"price"];
        self.quantity = [aDecoder decodeObjectForKey:@"quantity"];
        self.size = [aDecoder decodeObjectForKey:@"size"];
        self.taxPercentage = [aDecoder decodeObjectForKey:@"taxPercentage"];
        self.addedDate = [aDecoder decodeObjectForKey:@"addedDate"];
        self.basketProducts = [aDecoder decodeObjectForKey:@"basketProducts"];
        self.product = [aDecoder decodeObjectForKey:@"product"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.price forKey:@"price"];
    [aCoder encodeObject:self.quantity forKey:@"quantity"];
    [aCoder encodeObject:self.size forKey:@"size"];
    [aCoder encodeObject:self.taxPercentage forKey:@"taxPercentage"];
    [aCoder encodeObject:self.addedDate forKey:@"addedDate"];
    [aCoder encodeObject:self.basketProducts forKey:@"basketProducts"];
    [aCoder encodeObject:self.product forKey:@"product"];
}

- (id)jsonObject
{
    return [WAProductInstanceModelHelper jsonObjectWithDetail:NO andProductInstance:self];
}

- (id)jsonObjectWithDetail:(BOOL)detail
{
    return [WAProductInstanceModelHelper jsonObjectWithDetail:detail andProductInstance:self];
}

- (BOOL)isSizeBased
{
    return [WAProductInstanceModelHelper isSizeBasedWithSize:self.size];
}

@end
