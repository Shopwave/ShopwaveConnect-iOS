#import "WACategoryModelHelper.h"
#import "WAUrl.h"

@interface WACategoryModelHelper ()

#pragma mark - PrivateHelper Methods
+ (NSError *)errorWithDescription:(NSString *)description andRecoverySuggestion:(NSString *)recoverySuggestion;

@end

@implementation WACategoryModelHelper

+ (NSString *)descriptionFromCategory:(NSObject <WACategoryProtocol> *)category
{
    return [NSString stringWithFormat:@"%@ : %@", category.identifier, category.title];
}

+ (id)jsonObjectWithCategory:(NSObject <WACategoryProtocol> *)category andDetail:(BOOL)detail
{
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    
    if (category.identifier != nil)
    {
        [jsonDictionary setObject:category.identifier forKey:@"id"];
    }
    
    if (category.title != nil)
    {
        [jsonDictionary setObject:category.title forKey:@"title"];
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //In the format matching 2013-07-22 13:00:00
    
    [jsonDictionary setObject:category.activeDate != nil ? [dateFormat stringFromDate:category.activeDate] : [NSNull null] forKey:@"activeDate"];
    
    [jsonDictionary setObject:category.deleteDate != nil ? [dateFormat stringFromDate:category.deleteDate] : [NSNull null] forKey:@"deleteDate"];
    
    if (category.parentIdentifier != nil)
    {
        [jsonDictionary setObject:category.parentIdentifier forKey:@"parentId"];
    }
    else if (category.parentIdentifier == nil  && category.parentCategory.identifier != nil)
    {
        [jsonDictionary setObject:category.parentCategory.identifier forKey:@"parentId"];
    }
    else
    {
        [jsonDictionary setObject:[NSNull null] forKey:@"parentId"];
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

+ (NSError *)validForUploadWithTitle:(NSString *)title
{
    NSError *error = nil;
    
    BOOL titleCharacterExists = [title rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location != NSNotFound;
    
    if (title == nil || [title isEqualToString:@""] || [title isEqualToString:@" "] || !titleCharacterExists)
    {
        return [self errorWithDescription:NSLocalizedString(@"WACMH.Invalid Title", nil)
                    andRecoverySuggestion:NSLocalizedString(@"WACMH.Please enter a title or ensure that it is not empty.", nil)];
    }
    
    return error;
}

#pragma mark - PrivateHelper Methods

+ (NSError *)errorWithDescription:(NSString *)description andRecoverySuggestion:(NSString *)recoverySuggestion
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:description forKey:NSLocalizedDescriptionKey];
    [userInfo setObject:recoverySuggestion forKey:NSLocalizedRecoverySuggestionErrorKey];
    
    return [NSError errorWithDomain:[NSString stringWithFormat:@"%@ Error", [self class]] code:0 userInfo:userInfo];
}

@end
