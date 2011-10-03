//
//  ATFbEventStatus.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ATFacebookConnecter.h"

@class ATFbEventStatus;

@interface ATFbEventStatusManager : NSObject {
    
}
+ (ATFbEventStatusManager *)sharedATFbEventStatusManager;
+ (ATFbEventStatus *)fbEventStatusWithJson:(NSString *)jsonString;
+ (NSMutableArray *)arrayDispForStatusSelect;
+ (void)setRsvpStatus:(ATFbEventStatus *)eventStatus selectedIndex:(NSUInteger)index;
+ (NSString *)stringDispStatus:(ATFbEventStatus *)fbEventStatus;
@end

@interface ATFbEventStatus : NSObject {
    id _eid;
    id _uid;
    ATFacebookRsvpStatus _status;
}
@property (nonatomic, retain) id eid;
@property (nonatomic, retain) id uid;
@property (nonatomic) ATFacebookRsvpStatus status;

@end
