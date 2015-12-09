#import "WACategoryParser.h"
#import "WAUnmanagedCategory.h"

@implementation WACategoryParser

- (void)parseData:(NSData *)data withWarnings:(NSDictionary *)warnings
{
    [super parseData:data withWarnings:warnings];
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (error == nil && [NSJSONSerialization isValidJSONObject:json])
    {
        NSDictionary *categoriesDictionary = [json objectForKey:@"categories"];
        NSMutableDictionary *unmanagedCategories = [[NSMutableDictionary alloc] init];
        
        for (id key in categoriesDictionary)
        {
            NSDictionary *subDictionary = [categoriesDictionary objectForKey:key];
            
            WAUnmanagedCategory *unmanagedCategory = [[WAUnmanagedCategory alloc] init];
            unmanagedCategory.identifier = [NSNumber numberWithInt:[self parseIntWithObject:[subDictionary objectForKey:@"id"]]];
            
            int parentId = [self parseIntWithObject:[subDictionary objectForKey:@"parentId"]];
            if (parentId != -1)
            {
                WAUnmanagedCategory *tempParentCategory = [[WAUnmanagedCategory alloc] init];
                tempParentCategory.identifier = [NSNumber numberWithInt:parentId];
                
                unmanagedCategory.parentCategory = tempParentCategory;
            }
            else
            {
                unmanagedCategory.parentCategory = nil;
            }
            
            unmanagedCategory.title = [self parseStringWithObject:[subDictionary objectForKey:@"title"]];
            
            NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
            [startDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
            
            NSString *activeDateString = [self parseStringWithObject:[subDictionary objectForKey:@"activeDate"]];
            
            if (activeDateString != nil)
            {
                unmanagedCategory.activeDate = [startDateFormatter dateFromString:activeDateString];
            }
            
            NSString *deleteDateString = [self parseStringWithObject:[subDictionary objectForKey:@"deleteDate"]];
            
            if (deleteDateString != nil)
            {
                unmanagedCategory.deleteDate = [startDateFormatter dateFromString:deleteDateString];
            }
            
            [unmanagedCategories setObject:unmanagedCategory forKey:key];
        }
        
        if ([self.delegate respondsToSelector:@selector(parser:didParseCategories:)])
        {
            [self.delegate parser:self didParseCategories:unmanagedCategories];
        }
    }
    else
    {
        [self dispatchErrorWithTitle:NSLocalizedString(@"WACP.No Categories Found", nil)
                          andMessage:NSLocalizedString(@"WACP.Please try adding some categories in settings.", nil)];
    }    
}

@end
