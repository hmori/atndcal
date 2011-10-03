//
//  ATOperationManager.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATOperationManager.h"
#import "ObjectSingleton.h"

@interface ATOperationManager ()
- (id)init;
@end

@implementation ATOperationManager

OBJECT_SINGLETON_TEMPLATE(ATOperationManager, sharedATOperationManager)

- (id)init {
    if ((self = [super init])) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)dealloc {
    [_queue release];
    [super dealloc];
}

#pragma mark - Public

- (void)addOperation:(NSOperation *)operatoin {
    [_queue addOperation:operatoin];
}

- (void)cancelAllOperationOfName:(NSString *)aName {
    for (NSOperation *operation in [_queue operations]) {
        if ([operation isKindOfClass:ATRequestOperation.class]){
            if ([[(ATRequestOperation *)operation notificationName] isEqualToString:aName]) {
                [(ATRequestOperation *)operation cancel];
                ((ATRequestOperation *)operation).delegate = nil;
            }
        }
    }
}

@end
