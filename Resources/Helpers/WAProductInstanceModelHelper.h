#import <Foundation/Foundation.h>

@protocol WAProductInstanceProtocol;

@interface WAProductInstanceModelHelper : NSObject

#pragma mark - ProductInstanceProtocolHelper Methods
+ (id)jsonObjectWithDetail:(BOOL)detail andProductInstance:(NSObject <WAProductInstanceProtocol> *)productInstance;
+ (BOOL)isSizeBasedWithSize:(NSDecimalNumber *)size;

@end
