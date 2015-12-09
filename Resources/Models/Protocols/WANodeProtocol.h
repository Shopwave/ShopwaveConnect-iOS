#import <Foundation/Foundation.h>

@class WANode;

@protocol WANodeProtocol <NSObject>

@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSNumber *parentIdentifier;
@property (nonatomic, strong) NSObject <WANodeProtocol> *parentNode;
@property (nonatomic, strong) NSMutableArray *children;

@end
