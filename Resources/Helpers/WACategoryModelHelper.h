#import <Foundation/Foundation.h>
#import "WACategoryProtocol.h"

@interface WACategoryModelHelper : NSObject

+ (NSString *)descriptionFromCategory:(NSObject <WACategoryProtocol> *)category;
+ (id)jsonObjectWithCategory:(NSObject <WACategoryProtocol> *)category andDetail:(BOOL)detail;
+ (BOOL)validForDeletionWithIdentifier:(NSNumber *)identifier;
+ (NSError *)validForUploadWithTitle:(NSString *)title;

@end
