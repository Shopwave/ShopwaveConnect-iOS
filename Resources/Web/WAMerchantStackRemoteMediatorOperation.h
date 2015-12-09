#import "WARemoteMediatorOperation.h"

@class WALocalMediatorOperation;

@interface WAMerchantStackRemoteMediatorOperation : WARemoteMediatorOperation
{
    WALocalMediatorOperation *currentUserOperation;
}
@end
