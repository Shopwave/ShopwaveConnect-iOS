#import "WAUnmanagedCategory.h"
#import "GTMNSString+HTML.h"
#import "WACategoryModelHelper.h"

@implementation WAUnmanagedCategory

@synthesize identifier, title, activeDate, deleteDate, products, parentCategory, subCategories, parentIdentifier, parentNode, children;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.deleteDate = [aDecoder decodeObjectForKey:@"deleteDate"];
        self.activeDate = [aDecoder decodeObjectForKey:@"activeDate"];
        self.products = [aDecoder decodeObjectForKey:@"products"];
        self.parentCategory = [aDecoder decodeObjectForKey:@"parentCategory"];
        self.subCategories = [aDecoder decodeObjectForKey:@"subCategories"];
        self.parentIdentifier = [aDecoder decodeObjectForKey:@"parentIdentifier"];
        self.parentNode = [aDecoder decodeObjectForKey:@"parentNode"];
        self.children = [aDecoder decodeObjectForKey:@"children"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.deleteDate forKey:@"deleteDate"];
    [aCoder encodeObject:self.activeDate forKey:@"activeDate"];
    [aCoder encodeObject:self.products forKey:@"products"];
    [aCoder encodeObject:self.parentCategory forKey:@"parentCategory"];
    [aCoder encodeObject:self.subCategories forKey:@"subCategories"];
    [aCoder encodeObject:self.parentIdentifier forKey:@"parentIdentifier"];
    [aCoder encodeObject:self.parentNode forKey:@"parentNode"];
    [aCoder encodeObject:self.children forKey:@"children"];
}

- (id)copyWithZone:(NSZone *)zone
{
    WAUnmanagedCategory *unmanagedCategory = [[[self class] allocWithZone:zone] init];
    
    if (unmanagedCategory)
    {
        [unmanagedCategory setIdentifier:[self identifier]];
        [unmanagedCategory setTitle:[self title]];
        [unmanagedCategory setActiveDate:[self activeDate]];
        [unmanagedCategory setDeleteDate:[self deleteDate]];
        [unmanagedCategory setProducts:[self products]];
        [unmanagedCategory setParentCategory:[self parentCategory]];
        [unmanagedCategory setSubCategories:[self subCategories]];
        [unmanagedCategory setParentIdentifier:[self parentIdentifier]];
        [unmanagedCategory setParentNode:[self parentNode]];
        [unmanagedCategory setChildren:[self children]];
    }
    
    return unmanagedCategory;
}

#pragma mark - CategoryProtocolHelper Methods

- (NSString *)description
{
    return [WACategoryModelHelper descriptionFromCategory:self];
}

- (NSError *)validForUpload
{
    return [WACategoryModelHelper validForUploadWithTitle:self.title];
}

- (BOOL)validForDeletion
{
    return [WACategoryModelHelper validForDeletionWithIdentifier:self.identifier];
}

- (id)jsonObject
{
    return [WACategoryModelHelper jsonObjectWithCategory:self andDetail:NO];
}

- (id)jsonObjectWithDetail:(BOOL)detail
{
    return [WACategoryModelHelper jsonObjectWithCategory:self andDetail:detail];
}

#pragma mark - PrivateHelper Methods

- (NSError *)errorWithDescription:(NSString *)description andRecoverySuggestion:(NSString *)recoverySuggestion
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:description forKey:NSLocalizedDescriptionKey];
    [userInfo setObject:recoverySuggestion forKey:NSLocalizedRecoverySuggestionErrorKey];
    
    return [NSError errorWithDomain:[NSString stringWithFormat:@"%@ Error", [self class]] code:0 userInfo:userInfo];
}

@end
