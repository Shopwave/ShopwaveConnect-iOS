#import "WAProductParser.h"
#import "WAUnmanagedProduct.h"
#import "WAUnmanagedCategory.h"
#import "NSDecimalNumber+Arithmetic.h"
#import "WAUnmanagedProductInstance.h"

@implementation WAProductParser

#pragma mark - PublicHelper Methods

- (void)parseData:(NSData *)data withWarnings:(NSDictionary *)warnings
{
    [super parseData:data withWarnings:warnings];
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (error == nil && [NSJSONSerialization isValidJSONObject:json])
    {
        NSDictionary *productsDictionary = [json objectForKey:@"products"];
        NSMutableDictionary *unmanagedProducts = [[NSMutableDictionary alloc] init];
        
        for (id key in productsDictionary)
        {
            if (![key isEqualToString:@"null"])
            {
                NSDictionary *productItemDictionary = [productsDictionary objectForKey:key];
                
                WAUnmanagedProduct *unmanagedProduct = [[WAUnmanagedProduct alloc] init];
                unmanagedProduct.identifier = [NSNumber numberWithInt:[self parseIntWithObject:[productItemDictionary objectForKey:@"id"]]];
                unmanagedProduct.barcode = [self parseStringWithObject:[productItemDictionary objectForKey:@"barcode"]];
                unmanagedProduct.name = [self parseStringWithObject:[productItemDictionary objectForKey:@"name"]];
                unmanagedProduct.details = [self parseStringWithObject:[productItemDictionary objectForKey:@"details"]];
                unmanagedProduct.unit = [NSNumber numberWithInt:[self parseIntWithObject:[productItemDictionary objectForKey:@"unit"]]];
                
                WAUnmanagedProductInstance *unmanagedProductInstance = [[WAUnmanagedProductInstance alloc] init];
                unmanagedProductInstance.identifier = [NSNumber numberWithInt:[self parseIntWithObject:[productItemDictionary objectForKey:@"productInstanceId"]]];
                unmanagedProductInstance.price = [NSDecimalNumber decimalNumberWithObject:[productItemDictionary objectForKey:@"price"]];
                unmanagedProductInstance.quantity = [NSDecimalNumber decimalNumberWithObject:[productItemDictionary objectForKey:@"quantity"]];
                unmanagedProductInstance.vatPercentage = [NSDecimalNumber decimalNumberWithObject:[productItemDictionary objectForKey:@"vatPercentage"]];
                unmanagedProductInstance.size = [NSDecimalNumber decimalNumberWithObject:[productItemDictionary objectForKey:@"size"]];
                
                NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
                [startDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];

                NSString *addedDateString = [self parseStringWithObject:[productItemDictionary objectForKey:@"productInstanceTimestamp"]];
                
                if (addedDateString != nil)
                {
                    unmanagedProductInstance.addedDate = [startDateFormatter dateFromString:addedDateString];
                }
                
                NSSet *productInstanceSet = [NSSet setWithObject:unmanagedProductInstance];
                unmanagedProduct.productInstances = productInstanceSet;
                
                NSString *deleteDateString = [self parseStringWithObject:[productItemDictionary objectForKey:@"deleteDate"]];
                
                if (deleteDateString != nil)
                {
                    unmanagedProduct.deleteDate = [startDateFormatter dateFromString:deleteDateString];
                }
                
                NSString *activeDateString = [self parseStringWithObject:[productItemDictionary objectForKey:@"activeDate"]];
                
                if (activeDateString != nil)
                {
                    NSDate *date = [startDateFormatter dateFromString:activeDateString];
                    unmanagedProduct.activeDate = date != nil ? date : [NSDate date];
                }
                
                NSArray *imageStringsArray = [productItemDictionary objectForKey:@"images"];
                NSData *imageStringsData = [NSKeyedArchiver archivedDataWithRootObject:imageStringsArray];
                unmanagedProduct.imageIds = imageStringsData;
                
                if ([productItemDictionary objectForKey:@"categories"] != nil)
                {
                    NSMutableSet *categories = [[NSMutableSet alloc] init];
                    
                    for (NSString *categoryKey in [[productItemDictionary objectForKey:@"categories"] allKeys])
                    {
                        int identifier = [self parseIntWithObject:categoryKey];
                        
                        if (identifier != -1)
                        {
                            WAUnmanagedCategory *category = [[WAUnmanagedCategory alloc] init];
                            category.identifier = [NSNumber numberWithInt:identifier];
                            category.title = [self parseStringWithObject:[[productItemDictionary objectForKey:@"categories"] objectForKey:categoryKey]];
                            
                            [categories addObject:category];
                        }
                    }
                    
                    unmanagedProduct.categories = categories;
                }
                                
                [unmanagedProducts setObject:unmanagedProduct forKey:unmanagedProduct.identifier];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(parser:didParseProducts:)])
        {
            [self.delegate parser:self didParseProducts:unmanagedProducts];
        }
    }
    else
    {
        [self dispatchErrorWithTitle:NSLocalizedString(@"WAProductP.No Products Found", nil)
                          andMessage:NSLocalizedString(@"WAProductP.Please try adding some products in settings.", nil)];
    }
}

@end
