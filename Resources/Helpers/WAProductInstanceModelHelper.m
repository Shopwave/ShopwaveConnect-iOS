#import "WAProductInstanceModelHelper.h"
#import "WAProductInstanceProtocol.h"
#import "NSDecimalNumber+Arithmetic.h"

@implementation WAProductInstanceModelHelper

#pragma mark - ProductInstanceProtocolHelper Methods

+ (id)jsonObjectWithDetail:(BOOL)detail andProductInstance:(NSObject <WAProductInstanceProtocol> *)productInstance
{
    if (detail && productInstance != nil)
    {
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
        
        if (productInstance.identifier != nil)
        {
            [tempDictionary setObject:productInstance.identifier forKey:@"id"];
        }
        
        if (productInstance.price != nil)
        {
            [tempDictionary setObject:productInstance.price forKey:@"price"];
        }
        
        if (productInstance.vatPercentage != nil)
        {
            [tempDictionary setObject:productInstance.taxPercentage forKey:@"taxPercentage"];
        }
        
        if (productInstance.addedDate != nil)
        {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//In the format matching 2013-07-22 13:00:00
            
            [tempDictionary setObject:[dateFormat stringFromDate:productInstance.addedDate] forKey:@"addedDate"];
        }
        
        return tempDictionary;
    }
    
    return nil;
}

+ (BOOL)isSizeBasedWithSize:(NSDecimalNumber *)size
{
    if (size != nil && ![NSDecimalNumber equalToZeroWithDecimalNumber:size])
    {
        return YES;
    }
    
    return NO;
}

@end
