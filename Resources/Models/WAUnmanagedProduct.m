#import "WAUnmanagedProduct.h"
#import "NSDecimalNumber+Arithmetic.h"
#import "WACategoryProtocol.h"
#import "GTMNSString+HTML.h"
#import "WAUnmanagedProductInstance.h"
#import "WAProductModelHelper.h"

@implementation WAUnmanagedProduct

@synthesize activeDate, barcode, deleteDate, details, identifier, imageIds, name, price, unit, taxPercentage, basketProducts, categories, productInstances;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.activeDate = [aDecoder decodeObjectForKey:@"activeDate"];
        self.barcode = [aDecoder decodeObjectForKey:@"barcode"];
        self.deleteDate = [aDecoder decodeObjectForKey:@"deleteDate"];
        self.details = [aDecoder decodeObjectForKey:@"details"];
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.imageIds = [aDecoder decodeObjectForKey:@"imageIds"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.price = [aDecoder decodeObjectForKey:@"price"];
        self.unit = [aDecoder decodeObjectForKey:@"unit"];
        self.taxPercentage = [aDecoder decodeObjectForKey:@"taxPercentage"];
        self.basketProducts = [aDecoder decodeObjectForKey:@"basketProducts"];
        self.categories = [aDecoder decodeObjectForKey:@"categories"];
        self.productInstances = [aDecoder decodeObjectForKey:@"productInstances"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.activeDate forKey:@"activeDate"];
    [aCoder encodeObject:self.barcode forKey:@"barcode"];
    [aCoder encodeObject:self.deleteDate forKey:@"deleteDate"];
    [aCoder encodeObject:self.details forKey:@"details"];
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.imageIds forKey:@"imageIds"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.price forKey:@"price"];
    [aCoder encodeObject:self.unit forKey:@"unit"];
    [aCoder encodeObject:self.taxPercentage forKey:@"taxPercentage"];
    [aCoder encodeObject:self.basketProducts forKey:@"basketProducts"];
    [aCoder encodeObject:self.categories forKey:@"categories"];
    [aCoder encodeObject:self.productInstances forKey:@"productInstances"];
}

- (BOOL)isEqual:(id)object
{
    if (object == self)
    {
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]])
    {
        return NO;
    }
    
    return [self isEqualToProduct:object];
}

- (BOOL)isEqualToProduct:(WAUnmanagedProduct *)product
{
    if (self == product)
    {
        return YES;
    }
    
    if (!((id)[self activeDate] == nil && [product activeDate] == nil) && ![(id)[self activeDate] isEqual:[product activeDate]])
    {
        return NO;
    }
    
    if (!((id)[self barcode] == nil && [product barcode] == nil) && ![(id)[self barcode] isEqual:[product barcode]])
    {
        return NO;
    }
    
    if (!((id)[self deleteDate] == nil && [product deleteDate] == nil) && ![(id)[self deleteDate] isEqual:[product deleteDate]])
    {
        return NO;
    }
    
    if (!((id)[self details] == nil && [product details] == nil) && ![(id)[self details] isEqual:[product details]])
    {
        return NO;
    }

    if (!((id)[self identifier] == nil && [product identifier] == nil) && ![(id)[self identifier] isEqual:[product identifier]])
    {
        return NO;
    }

    if (!((id)[self imageIds] == nil && [product imageIds] == nil) && ![(id)[self imageIds] isEqual:[product imageIds]])
    {
        return NO;
    }
    
    if (!((id)[self name] == nil && [product name] == nil) && ![(id)[self name] isEqual:[product name]])
    {
        return NO;
    }
    
    if (!((id)[self price] == nil && [product price] == nil) && ![(id)[self price] isEqual:[product price]])
    {
        return NO;
    }
    
    if (!((id)[self purchaseCount] == nil && [product purchaseCount] == nil) && ![(id)[self purchaseCount] isEqual:[product purchaseCount]])
    {
        return NO;
    }
    
    if (!((id)[self unit] == nil && [product unit] == nil) && ![(id)[self unit] isEqual:[product unit]])
    {
        return NO;
    }
    
    if (!((id)[self vatPercentage] == nil && [product vatPercentage] == nil) && ![(id)[self vatPercentage] isEqual:[product vatPercentage]])
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - ProductProtocolHelper Methods

- (id)copyWithZone:(NSZone *)zone
{
    WAUnmanagedProduct *unmanagedProduct = [[[self class] allocWithZone:zone] init];
    
    if (unmanagedProduct)
    {
        [unmanagedProduct setActiveDate:[self activeDate]];
        [unmanagedProduct setBarcode:[self barcode]];
        [unmanagedProduct setDeleteDate:[self deleteDate]];
        [unmanagedProduct setDetails:[self details]];
        [unmanagedProduct setIdentifier:[self identifier]];
        [unmanagedProduct setImageIds:[self imageIds]];
        [unmanagedProduct setName:[self name]];
        [unmanagedProduct setPrice:[self price]];
        [unmanagedProduct setPurchaseCount:[self purchaseCount]];
        [unmanagedProduct setUnit:[self unit]];
        [unmanagedProduct setVatPercentage:[self vatPercentage]];
        [unmanagedProduct setBasketProducts:[self basketProducts]];
        [unmanagedProduct setCategories:[self categories]];
        [unmanagedProduct setProductComponents:[self productComponents]];
        [unmanagedProduct setProductInstances:[self productInstances]];
    }
    
    return unmanagedProduct;
}

- (NSArray *)imageIdArray
{
    return [WAProductModelHelper imageIdArrayWithImageData:self.imageIds];
}

- (id)jsonObject
{
    return [WAProductModelHelper jsonObjectWithDetail:NO andProduct:self];
}

- (id)jsonObjectWithDetail:(BOOL)detail
{
    return [WAProductModelHelper jsonObjectWithDetail:detail andProduct:self];
}

- (NSDecimalNumber *)latestPrice
{
    return [WAProductModelHelper latestPriceWithProductInstances:self.productInstances];
}

- (NSDate *)latestProductInstanceAddedDate
{
    return [WAProductModelHelper latestProductInstanceAddedDateWithProductInstances:self.productInstances];
}

- (NSObject <WAProductInstanceProtocol> *)latestProductInstanceFromProductInstances
{
    return [WAProductModelHelper latestProductInstanceFromProductInstances:self.productInstances];
}

- (NSNumber *)latestProductInstanceIdentifier
{
    return [WAProductModelHelper latestProductInstanceIdentifierWithProductInstances:self.productInstances];
}

- (NSDecimalNumber *)latestTaxPercentage
{
    return [WAProductModelHelper latestTaxPercentageWithProductInstances:self.productInstances];
}

- (void)setLatestPrice:(NSDecimalNumber *)latestPrice
{
    [WAProductModelHelper setLatestPriceWithProductInstances:self.productInstances andPrice:latestPrice];
}

- (void)setLatestTaxPercentage:(NSDecimalNumber *)latestTaxPercentage
{
    [WAProductModelHelper setLatestTaxPercentageWithProductInstances:self.productInstances andTaxPercentage:latestTaxPercentage];
}

- (BOOL)validForDeletion
{
    return [WAProductModelHelper validForDeletionWithIdentifier:self.identifier];
}

- (NSError *)validForUpload
{
    return [WAProductModelHelper validForUploadWithProduct:self];
}

@end
