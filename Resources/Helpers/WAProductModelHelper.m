#import "WAProductModelHelper.h"
#import "WAProductInstanceProtocol.h"
#import "WAProductProtocol.h"
#import "NSDecimalNumber+Arithmetic.h"
#import "WACategoryProtocol.h"

@implementation WAProductModelHelper

+ (NSArray *)imageIdArrayWithImageData:(NSData *)imageData
{    
    return imageData != nil ? [NSKeyedUnarchiver unarchiveObjectWithData:imageData] : nil;
}

+ (id)jsonObjectWithDetail:(BOOL)detail andProduct:(NSObject <WAProductProtocol> *)product
{
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    
    if (product.identifier != nil)
    {
        [jsonDictionary setObject:product.identifier forKey:@"id"];
    }
    
    if (product.name != nil)
    {
        [jsonDictionary setObject:product.name forKey:@"name"];
    }
    
    if (product.details != nil)
    {
        [jsonDictionary setObject:product.details forKey:@"details"];
    }
    
    if (product.categories != nil && [product.categories count] > 0)
    {
        NSMutableArray *categoryIdentifiersArray = [[NSMutableArray alloc] init];
        
        for (NSObject <WACategoryProtocol> *category in [product.categories allObjects])
        {
            [categoryIdentifiersArray addObject:category.identifier];
        }
        
        [jsonDictionary setObject:categoryIdentifiersArray forKey:@"categories"];
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //In the format matching 2013-07-22 13:00:00
    
    [jsonDictionary setObject:product.activeDate != nil ? [dateFormat stringFromDate:product.activeDate] : [NSNull null] forKey:@"activeDate"];
    [jsonDictionary setObject:product.deleteDate != nil ? [dateFormat stringFromDate:product.deleteDate] : [NSNull null] forKey:@"deleteDate"];
    
    if ([self latestPriceWithProductInstances:product.productInstances] != nil)
    {
        [jsonDictionary setObject:[self latestPriceWithProductInstances:product.productInstances] forKey:@"price"];
    }
    
    if ([self latestTaxPercentageWithProductInstances:product.productInstances] != nil)
    {
        [jsonDictionary setObject:[self latestTaxPercentageWithProductInstances:product.productInstances] forKey:@"taxPercentage"];
    }
    
    if (detail && product.productInstances != nil && [product.productInstances count] > 0)
    {
        NSMutableDictionary *productInstanceDictionary = [[NSMutableDictionary alloc] init];
        
        for (NSObject <WAProductInstanceProtocol> *productInstance in [product.productInstances allObjects])
        {
            id productInstanceJson = [productInstance jsonObjectWithDetail:YES];
            
            if (productInstanceJson != nil)
            {
                [productInstanceDictionary setObject:productInstanceJson forKey:[productInstance.identifier stringValue]];
            }
        }
        
        if (productInstanceDictionary != nil && [productInstanceDictionary count] > 0)
        {
            [jsonDictionary setObject:productInstanceDictionary forKey:@"productInstances"];
        }
    }

    return jsonDictionary;
}

+ (BOOL)validForDeletionWithIdentifier:(NSNumber *)identifier
{
    if (identifier != nil)
    {
        return YES;
    }
    
    return NO;
}

+ (NSError *)validForUploadWithProduct:(NSObject <WAProductProtocol> *)product
{
    NSError *error = nil;
    
    NSDecimalNumber *latestPrice = [WAProductModelHelper latestPriceWithProductInstances:product.productInstances];
    NSDecimalNumber *latestTaxPercentage = [WAProductModelHelper latestTaxPercentageWithProductInstances:product.productInstances];
    
    if (product.name == nil || [product.name isEqualToString:@""] || [product.name isEqualToString:@" "])
    {
        return [self errorWithDescription:NSLocalizedString(@"WAPMH.Invalid Name", nil)
                    andRecoverySuggestion:NSLocalizedString(@"WAPMH.Please enter a name or ensure that it is not empty.", nil)];
    }
    else if (latestPrice == nil || [NSDecimalNumber lessThanZeroWithDecimalNumber:latestPrice])
    {
        return [self errorWithDescription:NSLocalizedString(@"WAPMH.Invalid Price", nil)
                    andRecoverySuggestion:NSLocalizedString(@"WAPMH.Please enter a price or ensure that it is greater than zero.", nil)];
    }
    else if (latestTaxPercentage == nil || [NSDecimalNumber lessThanZeroWithDecimalNumber:latestTaxPercentage])
    {
        return [self errorWithDescription:[NSString stringWithFormat:NSLocalizedString(@"WAPMH.Invalid %@ Percentage", nil), @"Tax"]
                    andRecoverySuggestion:[NSString stringWithFormat:NSLocalizedString(@"WAPMH.Please enter a %@ percentage or ensure that it is zero or greater.", nil), @"Tax"]];
    }
    else
    {
        return error;
    }
}

#pragma mark - PublicHelper Methods

+ (NSError *)errorWithDescription:(NSString *)description andRecoverySuggestion:(NSString *)recoverySuggestion
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:description forKey:NSLocalizedDescriptionKey];
    [userInfo setObject:recoverySuggestion forKey:NSLocalizedRecoverySuggestionErrorKey];
    
    return [NSError errorWithDomain:[NSString stringWithFormat:@"%@ Error", [self class]] code:0 userInfo:userInfo];
}

+ (NSObject <WAProductInstanceProtocol> *)latestProductInstanceFromProductInstances:(NSSet *)productInstances
{
    if (productInstances != nil && [productInstances count] > 0)
    {
        NSObject <WAProductInstanceProtocol> *currentProductInstance = nil;
        
        for (NSObject <WAProductInstanceProtocol> *tempProductInstance in [productInstances allObjects])
        {
            if (tempProductInstance.productComponent == nil)
            {
                if (currentProductInstance == nil)
                {
                    currentProductInstance = tempProductInstance;
                }
                else
                {
                    // tempPI addedDate is later cPI addedDate
                    if ([tempProductInstance.addedDate compare:currentProductInstance.addedDate] == NSOrderedDescending)
                    {
                        currentProductInstance = tempProductInstance;
                    }
                }
            }
        }
        
        return currentProductInstance;
    }
    
    return nil;
}

+ (NSDate *)latestProductInstanceAddedDateWithProductInstances:(NSSet *)productInstances
{
    return [self latestProductInstanceFromProductInstances:productInstances].addedDate;
}

+ (NSNumber *)latestProductInstanceIdentifierWithProductInstances:(NSSet *)productInstances
{
    return [self latestProductInstanceFromProductInstances:productInstances].identifier;
}

#pragma mark - PublicPrice Methods

+ (NSDecimalNumber *)latestPriceWithProductInstances:(NSSet *)productInstances
{
    return [self latestProductInstanceFromProductInstances:productInstances].price;
}

+ (NSDecimalNumber *)latestTaxPercentageWithProductInstances:(NSSet *)productInstances
{
    return [self latestProductInstanceFromProductInstances:productInstances].taxPercentage;
}

+ (void)setLatestPriceWithProductInstances:(NSSet *)productInstances andPrice:(NSDecimalNumber *)price
{
    [self latestProductInstanceFromProductInstances:productInstances].price = price;
}

+ (void)setLatestTaxPercentageWithProductInstances:(NSSet *)productInstances andTaxPercentage:(NSDecimalNumber *)taxPercentage
{
    [self latestProductInstanceFromProductInstances:productInstances].taxPercentage = taxPercentage;
}

@end
