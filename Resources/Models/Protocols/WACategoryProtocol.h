#import <Foundation/Foundation.h>

@protocol WACategoryProtocol <NSObject>

@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSSet *products;
@property (nonatomic, strong) NSDate *deleteDate;
@property (nonatomic, strong) NSDate *activeDate;
@property (nonatomic, strong) NSNumber *parentIdentifier;
@property (nonatomic, strong) NSObject <WACategoryProtocol> *parentCategory;

@optional

#pragma mark - Helper Methods
- (NSString *)description;
- (NSError *)validForUpload;
- (BOOL)validForDeletion;
- (id)jsonObject;
- (id)jsonObjectWithDetail:(BOOL)detail;

@end
