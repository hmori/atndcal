//
//  ATEventOutline.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATEventOutline.h"

#import "ObjectSingleton.h"
#import "ATEventForDate.h"
#import "ATEventForBookmark.h"
#import "ATEventForAttend.h"

@implementation ATEventOutlineManager

OBJECT_SINGLETON_TEMPLATE(ATEventOutlineManager, sharedATEventOutlineManager)

+ (NSMutableDictionary *)fetchDictionaryForCalendar {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSArray *arrayEventForData = [[ATEventForDateManager sharedATEventForDateManager] fetchAllData];
    for (ATEventForDate *eventForDate in arrayEventForData) {
        POOL_START;
        NSDate *date = eventForDate.date;
        NSMutableArray *eventArray = [dictionary objectForKey:date];
        if (!eventArray) {
            eventArray = [NSMutableArray arrayWithCapacity:0];
            [dictionary setObject:eventArray forKey:date];
        }
        ATEventOutline *eventOutline = [[[ATEventOutline alloc] init] autorelease];
        [eventOutline setEventObject:eventForDate.eventObject type:[eventForDate.type integerValue]];
        [eventOutline setManagedObjectIdentifier:eventForDate.identifier];
        [eventArray addObject:eventOutline];
        POOL_END;
    }
    return dictionary;
}

+ (NSMutableArray *)fetchArrayForBookmark {
    
    NSMutableArray *eventArray = [NSMutableArray arrayWithCapacity:0];
    NSArray *arrayEventForBookmark = [[ATEventForBookmarkManager sharedATEventForBookmarkManager] fetchAllData];
    for (ATEventForBookmark *eventForBookmark in arrayEventForBookmark) {
        POOL_START;
        ATEventOutline *eventOutline = [[[ATEventOutline alloc] init] autorelease];
        [eventOutline setEventObject:eventForBookmark.eventObject type:[eventForBookmark.type integerValue]];
        [eventOutline setManagedObjectIdentifier:eventForBookmark.identifier];
        [eventArray addObject:eventOutline];
        POOL_END;
    }
    return eventArray;
}

+ (NSMutableArray *)fetchArrayForAttend {
    
    NSMutableArray *eventArray = [NSMutableArray arrayWithCapacity:0];
    NSArray *arrayEventForAttend = [[ATEventForAttendManager sharedATEventForAttendManager] fetchAllData];
    for (ATEventForAttend *eventForAttend in arrayEventForAttend) {
        POOL_START;
        ATEventOutline *eventOutline = [[[ATEventOutline alloc] init] autorelease];
        [eventOutline setEventObject:eventForAttend.eventObject type:ATEventTypeAtnd];
        [eventOutline setManagedObjectIdentifier:eventForAttend.identifier];
        [eventArray addObject:eventOutline];
        POOL_END;
    }
    return eventArray;
}

+ (NSMutableArray *)arrayForEventObjects:(id)events {
    NSMutableArray *eventArray = [NSMutableArray arrayWithCapacity:0];
    if ([events isKindOfClass:NSArray.class]) {
        for (id event in events) {
            ATEventOutline *eventOutline = [[[ATEventOutline alloc] init] autorelease];
            [eventOutline setEventObject:event type:ATEventTypeAtnd];
            [eventArray addObject:eventOutline];
        }
    }
    return eventArray;
}

@end


@implementation ATEventOutline

@synthesize managedObjectIdentifier = _managedObjectIdentifier;
@synthesize isBookmark = _isBookmark;

- (void)dealloc {
    [_event release];
    [_fbEvent release];
    [_eventObject release];
    [_managedObjectIdentifier release];
    [super dealloc];
}

#pragma mark - setter

- (void)setEventObject:(NSString *)eventObject type:(ATEventType)type {
    if (_eventObject != eventObject) {
        [_eventObject release];
        _eventObject = [eventObject retain];
        
        _type = type;
        
        if (type == ATEventTypeAtnd) {
            _event = [[ATEventManager eventWithEventObject:eventObject] retain];
        } else if (type == ATEventTypeFacebook) {
            _fbEvent = [[ATFbEventManager fbEventWithFbEventObject:eventObject] retain];
        }
    }
}

#pragma mark - getter

- (id)eventObject {
    return _eventObject;
}

- (ATEventType)type {
    return _type;
}

- (NSString *)title {
    NSString *title = nil;
    if (_type == ATEventTypeAtnd) {
        title = _event.title;
    } else if (_type == ATEventTypeFacebook) {
        title = _fbEvent.name;
    }
    return title;
}

- (NSString *)date {
    NSString *date = nil;
    if (_type == ATEventTypeAtnd) {
        date = [ATEventManager stringForDispDate:_event];
    } else if (_type == ATEventTypeFacebook) {
        date = [ATFbEventManager stringForDispDate:_fbEvent];
    }
    return date;
}

- (NSString *)place {
    NSString *place = nil;
    if (_type == ATEventTypeAtnd) {
        place = _event.place;
    } else if (_type == ATEventTypeFacebook) {
        place = _fbEvent.location;
    }
    return place;
}

- (BOOL)isOver {
    NSDate *eventDate = nil;
    if (_type == ATEventTypeAtnd) {
        if ((NSNull *)_event.ended_at != [NSNull null]) {
            eventDate = [NSDate dateForAtndDateString:_event.ended_at];
        } else {
            eventDate = [NSDate dateForAtndDateString:_event.started_at];
        }
    } else if (_type == ATEventTypeFacebook) {
        NSDate *endDate = [NSDate dateConvertFromPstDate:
                           [NSDate dateWithTimeIntervalSince1970:[_fbEvent.end_time doubleValue]]];
        if (endDate) {
            eventDate = endDate;
        } else {
            eventDate = [NSDate dateConvertFromPstDate:
                         [NSDate dateWithTimeIntervalSince1970:[_fbEvent.start_time doubleValue]]];
        }
    }
    NSComparisonResult result = [eventDate compare:[NSDate date]];
    return (result == NSOrderedAscending);
}

@end
