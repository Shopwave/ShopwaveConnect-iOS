#import "WAParser.h"
#import "WAUnmanagedMessage.h"

@implementation WAParser

@synthesize delegate;

#pragma mark - PublicHelper Methods

- (void)parseData:(NSData *)data withWarnings:(NSDictionary *)warnings
{
    if ([self.delegate respondsToSelector:@selector(parser:didParseData:)])
    {
        [self.delegate parser:self didParseData:data];
    }
}

- (void)parseErrorsWithData:(NSData *)data
{
    NSError* error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    /* LOG ERRORS */
    
    NSDictionary *errorDictionary = [[[json objectForKey:@"api"] objectForKey:@"message"] objectForKey:@"errors"];
    
    NSMutableDictionary *parsedMessageDictionary = [[NSMutableDictionary alloc] init];
    
    if (errorDictionary != nil)
    {
        for (NSString *tempErrorKey in errorDictionary.allKeys)
        {
            WAUnmanagedMessage *message = [[WAUnmanagedMessage alloc] init];
            message.type = WAUnmanagedMessageTypeDevError;
            message.identifier = [self parseIntWithObject:[[errorDictionary objectForKey:tempErrorKey] objectForKey:@"id"]];
            message.code = [self parseStringWithObject:[[errorDictionary objectForKey:tempErrorKey] objectForKey:@"code"]];
            message.title = [self parseStringWithObject:[[errorDictionary objectForKey:tempErrorKey] objectForKey:@"title"]];
            message.details = [self parseStringWithObject:[[errorDictionary objectForKey:tempErrorKey] objectForKey:@"details"]];
            message.objectRef = [NSArray arrayWithArray:[[errorDictionary objectForKey:tempErrorKey] objectForKey:@"objectRef"]];
            
            [parsedMessageDictionary setObject:message forKey:[NSNumber numberWithInt:message.identifier]];
        }
    }
    
    /* LOG WARNINGS */
    
    NSDictionary *warningDictionary = [[[json objectForKey:@"api"] objectForKey:@"message"] objectForKey:@"warnings"];
    
    NSMutableDictionary *parsedWarningMessageDictionary = [[NSMutableDictionary alloc] init];
    
    if (warningDictionary != nil)
    {
        for (NSString *tempWarningKey in warningDictionary.allKeys)
        {
            WAUnmanagedMessage *message = [[WAUnmanagedMessage alloc] init];
            message.type = WAUnmanagedMessageTypeDevError;
            message.identifier = [self parseIntWithObject:[[warningDictionary objectForKey:tempWarningKey] objectForKey:@"id"]];
            message.code = [self parseStringWithObject:[[warningDictionary objectForKey:tempWarningKey] objectForKey:@"code"]];
            message.title = [self parseStringWithObject:[[warningDictionary objectForKey:tempWarningKey] objectForKey:@"title"]];
            message.details = [self parseStringWithObject:[[warningDictionary objectForKey:tempWarningKey] objectForKey:@"details"]];
            message.objectRef = [NSArray arrayWithArray:[[warningDictionary objectForKey:tempWarningKey] objectForKey:@"objectRef"]];
            
            [parsedWarningMessageDictionary setObject:message forKey:[NSNumber numberWithInt:message.identifier]];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(parser:didParseErrors:warnings:withData:)])
    {
        [self.delegate parser:self didParseErrors:parsedMessageDictionary warnings:parsedWarningMessageDictionary withData:data];
    }
}

- (void)dispatchErrorWithTitle:(NSString *)title andMessage:(NSString *)message
{
    if ([self.delegate respondsToSelector:@selector(parser:didNotParseWithError:)])
    {
        NSMutableDictionary *details = [[NSMutableDictionary alloc] init];
        [details setObject:title forKey:NSLocalizedDescriptionKey];
        [details setObject:message forKey:NSLocalizedRecoverySuggestionErrorKey];
        
        NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@ Error", [self class]] code:0 userInfo:details];
        
        [self.delegate parser:self didNotParseWithError:error];
    }
}

- (NSString *)parseStringWithObject:(NSObject *)newObject
{
    return newObject == nil || ![newObject isKindOfClass:[NSString class]] || ((NSString *)newObject).length == 0 || [((NSString *)newObject) isEqualToString:@"null"] ? nil : (NSString *)newObject;
}

- (NSNumber *)parseNumberWithObject:(NSObject *)newObject
{
    return newObject == nil || ![newObject isKindOfClass:[NSNumber class]] ? nil : (NSNumber *)newObject;
}

- (BOOL)parseBoolWithObject:(NSObject *)newObject
{
    if (newObject != nil)
    {
        if ([newObject isKindOfClass:[NSNumber class]])
        {
            return [((NSNumber *) newObject) boolValue];
        }
        else if ([newObject isKindOfClass:[NSString class]] && ![((NSString *)newObject) isEqualToString:@"null"])
        {
            return [((NSString *) newObject) boolValue];
        }
    }
    
    return NO;
}

- (int)parseIntWithObject:(NSObject *)newObject
{
    if (newObject != nil)
    {
        if ([newObject isKindOfClass:[NSNumber class]])
        {
            return [((NSNumber *) newObject) intValue];
        }
        else if ([newObject isKindOfClass:[NSString class]] && ![((NSString *)newObject) isEqualToString:@"null"])
        {
            return [((NSString *) newObject) intValue];
        }
    }
    
    return -1;
}

- (float)parseFloatWithObject:(NSObject *)newObject
{
    if (newObject != nil)
    {
        if ([newObject isKindOfClass:[NSNumber class]])
        {
            return [((NSNumber *) newObject) floatValue];
        }
        else if ([newObject isKindOfClass:[NSString class]] && ![((NSString *)newObject) isEqualToString:@"null"])
        {
            return [((NSString *) newObject) floatValue];
        }
    }
    
    return -1.0f;
}

@end
