#import <Foundation/Foundation.h>
#import "ATRequestOperation.h"

@interface ATOperationManager : NSObject {
    NSOperationQueue *_queue;
}
+ (ATOperationManager *)sharedATOperationManager;
- (void)addOperation:(NSOperation *)operatoin;
- (void)cancelAllOperationOfName:(NSString *)aName;

@end
