#import "NSDecimalNumber+Arithmetic.h"
#import "WAAppSettings.h"
#import "WACurrency.h"

@implementation NSDecimalNumber (Arithmetic)

#pragma mark - GeneralHelper Methods

+ (NSDecimalNumber *)absoluteDecimalNumber:(NSDecimalNumber *)num
{
    if ([NSDecimalNumber lessThanZeroWithDecimalNumber:num])
    {
        NSDecimalNumber * negativeOne = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:0 isNegative:YES];
        
        return [num decimalNumberByMultiplyingBy:negativeOne];
    }
    else
    {
        return num;
    }
}

+ (NSDecimalNumber *)decimalNumberWithObject:(id)object
{
    if ([object isKindOfClass:[NSString class]])
    {
        return  [NSDecimalNumber decimalNumberWithString:(NSString *)object];
    }
    else if ([object respondsToSelector:@selector(stringValue)])
    {
        return [NSDecimalNumber decimalNumberWithString:[object stringValue]];
    }
    
    return nil;
}

+ (NSDecimalNumber *)ceilingDecimalNumber:(NSDecimalNumber *)num
{
    return [num decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO]];
}

+ (NSDecimalNumber *)flooredDecimalNumber:(NSDecimalNumber *)num
{
    return [num decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO]];
}

+ (NSDecimalNumber *)roundedDecimalNumber:(NSDecimalNumber *)num
{
    return [num decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO]];
}

+ (BOOL)decimalNumber:(NSDecimalNumber *)num equalToDecimalNumber:(NSDecimalNumber *)num2
{
    return ![NSDecimalNumber decimalNumber:num lessThanDecimalNumber:num2] && ![NSDecimalNumber decimalNumber:num greaterThanDecimalNumber:num2];
}

+ (BOOL)decimalNumber:(NSDecimalNumber *)num greaterThanDecimalNumber:(NSDecimalNumber *)num2
{
    return [num compare:num2] == NSOrderedDescending;
}

+ (BOOL)decimalNumber:(NSDecimalNumber *)num lessThanDecimalNumber:(NSDecimalNumber *)num2
{
    return [num compare:num2] == NSOrderedAscending;
}

+ (BOOL)equalToZeroWithDecimalNumber:(NSDecimalNumber *)num
{
    return [NSDecimalNumber decimalNumber:num equalToDecimalNumber:[NSDecimalNumber zero]];
}

+ (BOOL)greaterThanZeroWithDecimalNumber:(NSDecimalNumber *)num
{
    return [NSDecimalNumber decimalNumber:num greaterThanDecimalNumber:[NSDecimalNumber zero]];
}

+ (BOOL)lessThanZeroWithDecimalNumber:(NSDecimalNumber *)num
{
    return [NSDecimalNumber decimalNumber:num lessThanDecimalNumber:[NSDecimalNumber zero]];
}

#pragma mark - StringConversion Methods

+ (NSString *)absolutePriceStringFromDecimalNumber:(NSDecimalNumber *)number
{
    NSDecimalNumber *tempNumber = [NSDecimalNumber absoluteDecimalNumber:[NSDecimalNumber roundedDecimalNumber:number]];
    int decimalDigitsInt = [WACurrency decimalDigitsInt];
    NSNumberFormatter *tempNumberFormatter = [self numberFormatterWithMinimumFractionDigits:decimalDigitsInt maximumFractionDigits:decimalDigitsInt andMinimumIntegerDigits:1];
    
    return [NSString stringWithFormat:@"%@%@", [WACurrency currentCurrencySymbol], [tempNumberFormatter stringFromNumber:[tempNumber decimalNumberByMultiplyingByPowerOf10:-decimalDigitsInt]]];
}

+ (NSString *)priceStringFromDecimalNumber:(NSDecimalNumber *)number
{
    return [self priceStringFromDecimalNumber:number withDecimalDigits:[WACurrency decimalDigitsInt]];
}

+ (NSString *)priceStringFromDecimalNumber:(NSDecimalNumber *)number withDecimalDigits:(int)decimalDigits
{
    return [self priceStringFromDecimalNumber:number withDecimalDigits:decimalDigits andCurrencySymbol:[WACurrency currentCurrencySymbol]];
}

+ (NSString *)priceStringFromDecimalNumber:(NSDecimalNumber *)number withDecimalDigits:(int)decimalDigits andCurrencySymbol:(NSString *)currencySymbol
{
    NSDecimalNumber *tempNumber = [NSDecimalNumber absoluteDecimalNumber:[NSDecimalNumber roundedDecimalNumber:number]];
    NSNumberFormatter *tempNumberFormatter = [self numberFormatterWithMinimumFractionDigits:decimalDigits maximumFractionDigits:decimalDigits andMinimumIntegerDigits:1];
    
    return [NSString stringWithFormat:@"%@%@%@", [self lessThanZeroWithDecimalNumber:number] ? @"-" : @"", currencySymbol, [tempNumberFormatter stringFromNumber:[tempNumber decimalNumberByMultiplyingByPowerOf10:-decimalDigits]]];
}

+ (NSString *)percentStringFromDecimalNumber:(NSDecimalNumber *)number
{
    NSDecimalNumber *tempNumber = [NSDecimalNumber absoluteDecimalNumber:[NSDecimalNumber roundedDecimalNumber:number]];
    NSNumberFormatter *tempNumberFormatter = [self numberFormatterWithMinimumFractionDigits:2 maximumFractionDigits:2 andMinimumIntegerDigits:1];
    
    return [NSString stringWithFormat:@"%@%@%%", [self lessThanZeroWithDecimalNumber:number] ? @"-" : @"", [tempNumberFormatter stringFromNumber:[tempNumber decimalNumberByMultiplyingByPowerOf10:-2]]];
}

+ (NSString *)taxPercentageStringFromDecimalNumber:(NSDecimalNumber *)number
{
    NSNumberFormatter *tempNumberFormatter = [self numberFormatterWithMinimumFractionDigits:0 maximumFractionDigits:2 andMinimumIntegerDigits:1];
    
    return [NSString stringWithFormat:@"%@%%", [tempNumberFormatter stringFromNumber:[number decimalNumberByMultiplyingByPowerOf10:2]]];
}

#pragma mark - Pricing Methods

+ (NSDecimalNumber *)price:(NSDecimalNumber *)price multipliedByPriceSchemePricePercentage:(NSDecimalNumber *)pricePercentage
{
    return [price decimalNumberByMultiplyingBy:[pricePercentage decimalNumberByAdding:[NSDecimalNumber one]]];
}

+ (NSDecimalNumber *)priceExcludingTaxWithPrice:(NSDecimalNumber *)price andTaxPercentage:(NSDecimalNumber *)taxPercentage
{
    NSDecimalNumber *alteredTaxPercentage = [taxPercentage decimalNumberByAdding:[NSDecimalNumber one]];
    
    return [NSDecimalNumber ceilingDecimalNumber:[price decimalNumberByDividingBy:alteredTaxPercentage]];
}

+ (NSDecimalNumber *)priceIncludingTaxWithPrice:(NSDecimalNumber *)price andTaxPercentage:(NSDecimalNumber *)taxPercentage
{
    return [[NSDecimalNumber ceilingDecimalNumber:price] decimalNumberByAdding:[self taxFromPrice:price andTaxPercentage:taxPercentage]];
}

+ (NSDecimalNumber *)priceExcludingTaxWithPrice:(NSDecimalNumber *)price andTaxPercentage:(NSDecimalNumber *)taxPercentage forQuantity:(NSDecimalNumber *)quantity
{
    return [NSDecimalNumber totalPriceExcludingTaxWithItemPrice:price andTaxPercentage:taxPercentage forQuantity:quantity];
}

+ (NSDecimalNumber *)priceIncludingTaxWithPrice:(NSDecimalNumber *)price andTaxPercentage:(NSDecimalNumber *)taxPercentage forQuantity:(NSDecimalNumber *)quantity
{
    return [NSDecimalNumber totalPriceIncludingTaxWithItemPrice:price andTaxPercentage:taxPercentage forQuantity:quantity];
}

+ (NSDecimalNumber *)totalPriceExcludingTaxWithItemPrice:(NSDecimalNumber *)price andTaxPercentage:(NSDecimalNumber *)taxPercentage forQuantity:(NSDecimalNumber *)quantity
{
    return [[NSDecimalNumber priceExcludingTaxWithPrice:price andTaxPercentage:taxPercentage] decimalNumberByMultiplyingBy:quantity];
}

+ (NSDecimalNumber *)totalPriceIncludingTaxWithItemPrice:(NSDecimalNumber *)price andTaxPercentage:(NSDecimalNumber *)taxPercentage forQuantity:(NSDecimalNumber *)quantity
{
    return [[NSDecimalNumber priceIncludingTaxWithPrice:price andTaxPercentage:taxPercentage] decimalNumberByMultiplyingBy:quantity];
}

+ (NSDecimalNumber *)taxFromPrice:(NSDecimalNumber *)price andTaxPercentage:(NSDecimalNumber *)taxPercentage
{
    return [NSDecimalNumber flooredDecimalNumber:[price decimalNumberByMultiplyingBy:taxPercentage]];
}

+ (NSDecimalNumber *)taxFromPrice:(NSDecimalNumber *)price andTaxPercentage:(NSDecimalNumber *)taxPercentage forQuantity:(NSDecimalNumber *)quantity
{
    return [[NSDecimalNumber taxFromPrice:price andTaxPercentage:taxPercentage] decimalNumberByMultiplyingBy:quantity];
}

#pragma mark - PrivateHelper Methods

+ (NSNumberFormatter *)numberFormatterWithMinimumFractionDigits:(int)minimumFractionDigits maximumFractionDigits:(int)maximumFractionDigits andMinimumIntegerDigits:(int)minimumIntegerDigits
{
    NSNumberFormatter *tempNumberFormatter = [[NSNumberFormatter alloc] init];
    tempNumberFormatter.minimumFractionDigits = minimumFractionDigits;
    tempNumberFormatter.maximumFractionDigits = maximumFractionDigits;
    tempNumberFormatter.minimumIntegerDigits = minimumIntegerDigits;
    
    return tempNumberFormatter;
}

@end
