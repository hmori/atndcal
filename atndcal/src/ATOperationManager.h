//
//  ATOperationManager.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATRequestOperation.h"

@interface ATOperationManager : NSObject {
    NSOperationQueue *_queue;
}
+ (ATOperationManager *)sharedATOperationManager;
- (void)addOperation:(NSOperation *)operatoin;
- (void)cancelAllOperationOfName:(NSString *)aName;

@end
