//
//  ATEvent.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATEvent.h"
#import <TapkuLibrary/TapkuLibrary.h>
#import "ObjectSingleton.h"
#import "NSString+SBJSON.h"
#import "NSString+ATCategory.h"

@implementation ATEventManager

OBJECT_SINGLETON_TEMPLATE(ATEventManager, sharedATEventManager)

static NSString * const kResults_returned = @"results_returned";
static NSString * const kResults_start = @"results_start";

static NSString * const kEvents = @"events";

static NSString * const kEvent_id = @"event_id";
static NSString * const kTitle = @"title";
static NSString * const kCatch = @"catch";
static NSString * const kDescription = @"description";
static NSString * const kEvent_url = @"event_url";
static NSString * const kStarted_at = @"started_at";
static NSString * const kEnded_at = @"ended_at";
static NSString * const kUrl = @"url";
static NSString * const kLimit = @"limit";
static NSString * const kAddress = @"address";
static NSString * const kPlace = @"place";
static NSString * const kLat = @"lat";
static NSString * const kLon = @"lon";
static NSString * const kOwner_id = @"owner_id";
static NSString * const kOwner_nickname = @"owner_nickname";
static NSString * const kOwner_twitter_id = @"owner_twitter_id";
static NSString * const kAccepted = @"accepted";
static NSString * const kWaiting = @"waiting";
static NSString * const kUpdated_at = @"updated_at";


+ (NSDictionary *)dictionaryWithJson:(NSString *)jsonString {
    LOG_CURRENT_METHOD;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    
    id jsonData = [jsonString JSONValue];
	if ([jsonData isKindOfClass:NSDictionary.class]) {
        NSString *results_returned = [jsonData objectForKey:kResults_returned];
        NSString *results_start = [jsonData objectForKey:kResults_start];
        LOG(@"results_returned=%@", results_returned);
        LOG(@"results_start=%@", results_start);
        [dictionary setObject:results_returned forKey:kResults_returned];
        [dictionary setObject:results_start forKey:kResults_start];
        
        id events = [jsonData objectForKey:kEvents];
        [dictionary setObject:events forKey:kEvents];
    }
    return dictionary;
}

+ (ATEvent *)eventWithEventObject:(id)eventObject {
    ATEvent *event = nil;
    if ([eventObject isKindOfClass:NSDictionary.class]) {
        event = [[[ATEvent alloc] init] autorelease];
        event.event_id = [eventObject objectForKey:kEvent_id];
        event.title = [eventObject objectForKey:kTitle];
        event.catch_ = [eventObject objectForKey:kCatch];
        event.description_ = [eventObject objectForKey:kDescription];
        event.event_url = [eventObject objectForKey:kEvent_url];
        event.started_at = [eventObject objectForKey:kStarted_at];
        event.ended_at = [eventObject objectForKey:kEnded_at];
        event.url = [eventObject objectForKey:kUrl];
        event.limit = [eventObject objectForKey:kLimit];
        event.address = [eventObject objectForKey:kAddress];
        event.place = [eventObject objectForKey:kPlace];
        event.lat = [eventObject objectForKey:kLat];
        event.lon = [eventObject objectForKey:kLon];
        event.owner_id = [eventObject objectForKey:kOwner_id];
        event.owner_nickname = [eventObject objectForKey:kOwner_nickname];
        event.owner_twitter_id = [eventObject objectForKey:kOwner_twitter_id];
        event.accepted = [eventObject objectForKey:kAccepted];
        event.waiting = [eventObject objectForKey:kWaiting];
        event.updated_at = [eventObject objectForKey:kUpdated_at];
    }
    return event;
}

+ (NSString *)stringForDispDescription:(ATEvent *)event {
    LOG_CURRENT_METHOD;
    NSString *string = nil;
    string = [event.description_ stringByStrippingHTML];
    return string;
}

+ (NSString *)stringForDispCapacity:(ATEvent *)event {
    LOG_CURRENT_METHOD;
    
    static NSString *undecided = @"未定";
    static NSString *capacityFormat = @"%d / %@";
    
    NSString *string = nil;
    
    NSString *limitString = nil;
    if (!event.limit || (NSNull *)event.limit == [NSNull null]) {
        limitString = undecided;
    } else {
        limitString = event.limit;
    }
    
    if (event.accepted && event.waiting) {
        NSInteger iAccepted = [event.accepted integerValue];
        NSInteger iWaiting = [event.waiting integerValue];
        string = [NSString stringWithFormat:capacityFormat, 
                  (iAccepted+iWaiting), limitString];
    }
    return string;
}

+ (NSString *)stringForDispDate:(ATEvent *)event {
    
    static NSString *dateFormat = @"%@ %@";
    static NSString *separateFormat = @" -";
    static NSString *prefixSpaceFormat = @" %@";
    
    NSMutableString *string = [NSMutableString stringWithCapacity:0];
    NSDate *startDate = [NSDate dateForAtndDateString:event.started_at];
    if (startDate) {
        [string appendFormat:dateFormat, 
         [startDate stringForDispDateYmw],
         [startDate stringForDispDateHm]];
    }
    NSDate *endDate = [NSDate dateForAtndDateString:event.ended_at];
    if (endDate) {
        [string appendString:separateFormat];
        if (![startDate isSameDay:endDate]) {
            [string appendFormat:prefixSpaceFormat, [endDate stringForDispDateYmw]];
        }
        [string appendFormat:prefixSpaceFormat, [endDate stringForDispDateHm]];
    }
    return string;
}

+ (NSString *)stringForDispDate:(ATEvent *)event eventDate:(ATEventDate)eventDate {

    static NSString *dateFormat = @"%@ %@";

    NSString *string = nil;
    NSDate *date = nil;
    if (eventDate == ATEventDateStart) {
        date = [NSDate dateForAtndDateString:event.started_at];
    } else if (eventDate == ATEventDateEnd) {
        date = [NSDate dateForAtndDateString:event.ended_at];
    }
    if (date) {
        string = [NSString stringWithFormat:dateFormat, 
                  [date stringForDispDateYmw],
                  [date stringForDispDateHm]];
    }
    return string;
}


@end


@implementation ATEvent

@synthesize event_id = _event_id;
@synthesize title = _title;
@synthesize catch_ = _catch_;
@synthesize description_ = _description_;
@synthesize event_url = _event_url;
@synthesize started_at = _started_at;
@synthesize ended_at = _ended_at;
@synthesize url = _url;
@synthesize limit = _limit;
@synthesize address = _address;
@synthesize place = _place;
@synthesize lat = _lat;
@synthesize lon = _lon;
@synthesize owner_id = _owner_id;
@synthesize owner_nickname = _owner_nickname;
@synthesize owner_twitter_id = _owner_twitter_id;
@synthesize accepted = _accepted;
@synthesize waiting = _waiting;
@synthesize updated_at = _updated_at;

- (void)dealloc {
    [_event_id release];
    [_title release];
    [_catch_ release];
    [_description_ release];
    [_event_url release];
    [_started_at release];
    [_ended_at release];
    [_url release];
    [_limit release];
    [_address release];
    [_place release];
    [_lat release];
    [_lon release];
    [_owner_id release];
    [_owner_nickname release];
    [_owner_twitter_id release];
    [_accepted release];
    [_waiting release];
    [_updated_at release];
    [super dealloc];
}

#pragma mark - Public


@end
