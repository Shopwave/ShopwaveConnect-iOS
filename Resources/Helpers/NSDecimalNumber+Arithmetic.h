#import <Foundation/Foundation.h>

@interface NSDecimalNumber (Arithmetic)

#pragma mark - GeneralHelper Methods
+ (NSDecimalNumber *)absoluteDecimalNumber:(NSDecimalNumber *)num;
+ (NSDecimalNumber *)decimalNumberWithObject:(id)object;
+ (NSDecimalNumber *)ceilingDecimalNumber:(NSDecimalNumber *)num;
+ (NSDecimalNumber *)flooredDecimalNumber:(NSDecimalNumber *)num;
+ (NSDecimalNumber *)roundedDecimalNumber:(NSDecimalNumber *)num;
+ (BOOL)decimalNumber:(NSDecimalNumber *)num equalToDecimalNumber:(NSDecimalNumber *)num2;
+ (BOOL)decimalNumber:(NSDecimalNumber *)num greaterThanDecimalNumber:(NSDecimalNumber *)num2;
+ (BOOL)decimalNumber:(NSDecimalNumber *)num lessThanDecimalNumber:(NSDecimalNumber *)num2;
+ (BOOL)equalToZeroWithDecimalNumber:(NSDecimalNumber *)num;
+ (BOOL)greaterThanZeroWithDecimalNumber:(NSDecimalNumber *)num;
+ (BOOL)lessThanZeroWithDecimalNumber:(NSDecimalNumber *)num;

#pragma mark - StringConversion Methods
+ (NSString *)absolutePriceStringFromDecimalNumber:(NSDecimalNumber *)number;
+ (NSString *)priceStringFromDecimalNumber:(NSDecimalNumber *)number;
+ (NSString *)priceStringFromDecimalNumber:(NSDecimalNumber *)number withDecimalDigits:(int)decimalDigits;
+ (NSString *)priceStringFromDecimalNumber:(NSDecimalNumber *)number withDecimalDigits:(int)decimalDigits andCurrencySymbol:(NSString *)currencySymbol;
+ (NSString *)percentStringFromDecimalNumber:(NSDecimalNumber *)number;
+ (NSString *)taxPercentageStringFromDecimalNumber:(NSDecimalNumber *)number;

#pragma mark - Pricing Methods
+ (NSDecimalNumber *)price:(NSDecimalNumber *)price multipliedByPriceSchemePricePercentage:(NSDecimalNumber *)pricePercentage;
+ (NSDecimalNumber *)priceExcludingTaxWithPrice:(NSDecimalNumber *)price andTaxPercentage:(NSDecimalNumber *)taxPercentage;
+ (NSDecimalNumber *)priceIncludingTaxWithPrice:(NSDecimalNumber *)price andTaxPercentage:(NSDecimalNumber *)taxPercentage;
+ (NSDecimalNumber *)priceExcludingTaxWithPrice:(NSDecimalNumber *)price andTaxPercentage:(NSDecimalNumber *)taxPercentage forQuantity:(NSDecimalNumber *)quantity;
+ (NSDecimalNumber *)priceIncludingTaxWithPrice:(NSDecimalNumber *)price andTaxPercentage:(NSDecimalNumber *)taxPercentage forQuantity:(NSDecimalNumber *)quantity;
+ (NSDecimalNumber *)totalPriceExcludingTaxWithItemPrice:(NSDecimalNumber *)price andTaxPercentage:(NSDecimalNumber *)taxPercentage forQuantity:(NSDecimalNumber *)quantity;
+ (NSDecimalNumber *)totalPriceIncludingTaxWithItemPrice:(NSDecimalNumber *)price andTaxPercentage:(NSDecimalNumber *)taxPercentage forQuantity:(NSDecimalNumber *)quantity;
+ (NSDecimalNumber *)taxFromPrice:(NSDecimalNumber *)price andTaxPercentage:(NSDecimalNumber *)taxPercentage;
+ (NSDecimalNumber *)taxFromPrice:(NSDecimalNumber *)price andTaxPercentage:(NSDecimalNumber *)taxPercentage forQuantity:(NSDecimalNumber *)quantity;

@end
