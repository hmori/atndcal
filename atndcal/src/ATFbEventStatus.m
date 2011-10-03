//
//  ATFbEventStatus.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATFbEventStatus.h"
#import "ObjectSingleton.h"
#import "NSString+SBJSON.h"

@implementation ATFbEventStatusManager

OBJECT_SINGLETON_TEMPLATE(ATFbEventStatusManager, sharedATFbEventStatusManager)

static NSString * const dispNotReplied = @"未返信";
static NSString * const dispAttending = @"参加予定";
static NSString * const dispUnsure = @"未定";
static NSString * const dispDeclined = @"不参加";

static NSString * const kEid = @"eid";
static NSString * const kUid = @"uid";
static NSString * const kRsvp_status = @"rsvp_status";
static NSString * const kAttending = @"attending";
static NSString * const kUnsure = @"unsure";
static NSString * const kDeclined = @"declined";


+ (ATFbEventStatus *)fbEventStatusWithJson:(NSString *)jsonString {
    LOG_CURRENT_METHOD;
    
    ATFbEventStatus *fbEventStatus = nil;
    
    id jsonData = [jsonString JSONValue];
    if ([jsonData isKindOfClass:NSArray.class]) {
        for (id object in jsonData) {
            if ([object isKindOfClass:NSDictionary.class]) {
                id eid = [object objectForKey:kEid];
                id uid = [object objectForKey:kUid];
                id rsvp_status = [object objectForKey:kRsvp_status];
                if (rsvp_status && (NSNull *)rsvp_status != [NSNull null]) {
                    
                    ATFacebookRsvpStatus status = ATFacebookRsvpStatusNoreply;
                    if ([rsvp_status isEqualToString:kAttending]) {
                        status = ATFacebookRsvpStatusAttending;
                    } else if ([rsvp_status isEqualToString:kUnsure]) {
                        status = ATFacebookRsvpStatusMaybe;
                    } else if ([rsvp_status isEqualToString:kDeclined]) {
                        status = ATFacebookRsvpStatusDeclined;
                    }
                    fbEventStatus = [[[ATFbEventStatus alloc] init] autorelease];
                    fbEventStatus.eid = eid;
                    fbEventStatus.uid = uid;
                    fbEventStatus.status = status;
                    break;
                }
            }
        }
    }
    return fbEventStatus;
}

+ (NSMutableArray *)arrayDispForStatusSelect {
    return [NSMutableArray arrayWithObjects:dispAttending,dispUnsure,dispDeclined,nil];
}

+ (void)setRsvpStatus:(ATFbEventStatus *)eventStatus selectedIndex:(NSUInteger)index {
    if (index == 0) {
        eventStatus.status = ATFacebookRsvpStatusAttending;
    } else if (index == 1) {
        eventStatus.status = ATFacebookRsvpStatusMaybe;
    } else if (index == 2) {
        eventStatus.status = ATFacebookRsvpStatusDeclined;
    }
}

+ (NSString *)stringDispStatus:(ATFbEventStatus *)fbEventStatus {
    NSString *string = nil;
    if (fbEventStatus.status == ATFacebookRsvpStatusNoreply) {
        string = dispNotReplied;
    } else if (fbEventStatus.status == ATFacebookRsvpStatusAttending) {
        string = dispAttending;
    } else if (fbEventStatus.status == ATFacebookRsvpStatusMaybe) {
        string = dispUnsure;
    } else if (fbEventStatus.status == ATFacebookRsvpStatusDeclined) {
        string = dispDeclined;
    }
    return string;
}

@end

@implementation ATFbEventStatus
@synthesize eid = _eid;
@synthesize uid = _uid;
@synthesize status = _status;

- (void)dealloc {
    [_eid release];
    [_uid release];
    [super dealloc];
}

@end
