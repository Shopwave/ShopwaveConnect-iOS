#import "WAMerchantStackRemoteMediatorOperation.h"
#import "WALocalMediatorOperation.h"
#import "WAUserMediator.h"
#import "WAManagedUser.h"
#import "WAUrl.h"

@interface WAMerchantStackRemoteMediatorOperation () <WALocalMediatorOperationDelegate>

@property (nonatomic, strong) WALocalMediatorOperation *currentUserOperation;

@end

@implementation WAMerchantStackRemoteMediatorOperation

@synthesize currentUserOperation;

- (void)fetch
{
    self.currentUserOperation = [[WAUserMediator sharedUserMediator] currentUserWithDelegate:self];
}

#pragma mark - WAlocalMediatorOperationDelegate Methods

- (void)mediatorOperation:(WALocalMediatorOperation *)mediatorOperation didFetchDataArray:(NSArray *)dataArray
{
    switch (self.currentUserOperation.type)
    {
        case WALocalMediatorOperationTypeUserGet:
        {
            if (dataArray != nil && [dataArray count] > 0 && [[dataArray objectAtIndex:0] conformsToProtocol:@protocol(WAUserProtocol)])
            {
                WAManagedUser *user = [dataArray objectAtIndex:0];
                
                NSString *headerString = [NSString stringWithFormat:@"OAuth %@", user.accessToken];
                [self.url setHeader:headerString forKey:@"Authorization"];
                
                [super fetch];
            }
            
            break;
        }
        default:
            break;
    }
}

- (void) mediatorOperation:(WALocalMediatorOperation *)mediatorOperation didNotFetchDataArrayWithError:(NSError *)error
{
    [[WALogView sharedLogView] addLog:[[WALog alloc] initWithTitle:[NSString stringWithFormat:@"%@ FAIL", [self.url fetchTypeString]] description:[error description] type:WALogTypeDeveloper status:WALogStatusDead location:WALogLocationRemote]];
}

@end
