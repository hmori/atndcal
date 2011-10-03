//
//  ATEventForBookmark.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATEventForBookmark.h"

#import "ObjectSingleton.h"

#import "ATEvent.h"
#import "ATFbEvent.h"

@implementation ATEventForBookmarkManager

OBJECT_SINGLETON_TEMPLATE(ATEventForBookmarkManager, sharedATEventForBookmarkManager)

static NSString *EventForBookmark = @"EventForBookmark";

- (NSString *)entityName {
    return EventForBookmark;
}

- (NSError *)saveWithEventObject:(id)eventObject type:(ATEventType)type {

    NSString *eventId = nil;
    if (type == ATEventTypeAtnd) {
        ATEvent *event = [ATEventManager eventWithEventObject:eventObject];
        eventId = [NSString stringWithFormat:@"%@", event.event_id];
    } else if (type == ATEventTypeFacebook) {
        ATFbEvent *fbEvent = [ATFbEventManager fbEventWithFbEventObject:eventObject];
        eventId = [NSString stringWithFormat:@"%@", fbEvent.id_];
    }
    
    ATEventForBookmark *eventForBookmark = [[self new:EventForBookmark] autorelease];
    eventForBookmark.type = [NSNumber numberWithInt:type];
    eventForBookmark.eventId = eventId;
    eventForBookmark.eventObject = eventObject;
    eventForBookmark.createAt = [NSDate date];
    return [self save];
}

- (NSArray *)fetchAllData {
    return [self select:[self entityName] where:nil sortKey:@"createAt" ascending:NO];
}

- (ATEventForBookmark *)fetchEventForBookmarkFromEventId:(NSString *)eventId type:(ATEventType)type {
    ATEventForBookmark *eventForBookmark = nil;

    NSArray *result = [self select:[self entityName] where:[NSString stringWithFormat:@"eventId='%@' AND type=%d", eventId, type]];
    if (result.count > 0) {
        eventForBookmark = [result objectAtIndex:0];
    }
    return eventForBookmark;
}

- (NSInteger)removeObjectAtIdentifier:(NSString *)identifier {
    NSInteger count = [self deleteFrom:EventForBookmark identifier:identifier];
    if (count > 0) {
        [self save];
    }
    return count;
}

@end


@implementation ATEventForBookmark
@dynamic identifier;
@dynamic type;
@dynamic eventId;
@dynamic eventObject;
@dynamic createAt;
@end
