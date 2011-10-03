//
//  ATFbEvent.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATFbEvent.h"
#import <TapkuLibrary/TapkuLibrary.h>

#import "ObjectSingleton.h"
#import "NSString+SBJSON.h"

@implementation ATFbEventManager

OBJECT_SINGLETON_TEMPLATE(ATFbEventManager, sharedATFbEventManager)

static NSString * const kEid = @"eid";
static NSString * const kHost = @"host";
static NSString * const kName = @"name";
static NSString * const kDescription = @"description";
static NSString * const kStart_time = @"start_time";
static NSString * const kEnd_time = @"end_time";
static NSString * const kLocation = @"location";
static NSString * const kVenue = @"venue";
static NSString * const kPrivacy = @"privacy";
static NSString * const kUpdate_time = @"update_time";

static NSString * const timeZonePST = @"PST";

+ (NSArray *)arrayWithJson:(NSString *)jsonString {
    LOG_CURRENT_METHOD;
    
    NSMutableArray *array = nil;
    id jsonData = [jsonString JSONValue];
	if ([jsonData isKindOfClass:NSArray.class]) {
        array = [NSMutableArray arrayWithArray:jsonData];
    }
    return array;
}

+ (ATFbEvent *)fbEventWithFbEventObject:(id)fbEventObject {
    ATFbEvent *fbEvent = nil;
    if ([fbEventObject isKindOfClass:NSDictionary.class]) {
        fbEvent = [[[ATFbEvent alloc] init] autorelease];
        fbEvent.id_ = [fbEventObject objectForKey:kEid];
        fbEvent.owner = [fbEventObject objectForKey:kHost];
        fbEvent.name = [fbEventObject objectForKey:kName];
        fbEvent.description_ = [fbEventObject objectForKey:kDescription];
        fbEvent.start_time = [fbEventObject objectForKey:kStart_time];
        fbEvent.end_time = [fbEventObject objectForKey:kEnd_time];
        fbEvent.location = [fbEventObject objectForKey:kLocation];
        fbEvent.venue = [fbEventObject objectForKey:kVenue];
        fbEvent.privacy = [fbEventObject objectForKey:kPrivacy];
        fbEvent.updated_time = [fbEventObject objectForKey:kUpdate_time];
    }
    return fbEvent;
}

+ (NSString *)stringForDispDate:(ATFbEvent *)fbEvent {
    
    static NSString *dateFormat = @"%@ %@";
    static NSString *separateFormat = @" -";
    static NSString *prefixSpaceFormat = @" %@";

    NSMutableString *string = [NSMutableString stringWithCapacity:0];
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[fbEvent.start_time doubleValue]];
    if (startDate) {
        [string appendFormat:dateFormat, 
         [startDate stringForDispDateYmwWithTimeZone:[NSTimeZone timeZoneWithAbbreviation:timeZonePST]],
         [startDate stringForDispDateHmWithTimeZone:[NSTimeZone timeZoneWithAbbreviation:timeZonePST]]];
    }
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[fbEvent.end_time doubleValue]];
    if (endDate) {
        [string appendString:separateFormat];
        if (![startDate isSameDay:endDate]) {
            [string appendFormat:prefixSpaceFormat, 
             [endDate stringForDispDateYmwWithTimeZone:[NSTimeZone timeZoneWithAbbreviation:timeZonePST]]];
        }
        [string appendFormat:prefixSpaceFormat, 
         [endDate stringForDispDateHmWithTimeZone:[NSTimeZone timeZoneWithAbbreviation:timeZonePST]]];
    }
    return string;
}

+ (NSString *)stringForDispDate:(ATFbEvent *)fbEvent fbEventDate:(ATFbEventDate)fbEventDate {
    
    static NSString *dateFormat = @"%@ %@";

    NSString *string = nil;
    NSDate *date = nil;
    if (fbEventDate == ATFbEventDateStart) {
        date = [NSDate dateWithTimeIntervalSince1970:[fbEvent.start_time doubleValue]];
    } else if (fbEventDate == ATFbEventDateEnd) {
        date = [NSDate dateWithTimeIntervalSince1970:[fbEvent.end_time doubleValue]];
    }
    if (date) {
        string = [NSString stringWithFormat:dateFormat, 
                  [date stringForDispDateYmwWithTimeZone:[NSTimeZone timeZoneWithAbbreviation:timeZonePST]],
                  [date stringForDispDateHmWithTimeZone:[NSTimeZone timeZoneWithAbbreviation:timeZonePST]]];
    }
    return string;
}

+ (NSDate *)dateYmdStartTimeFromFbEvent:(ATFbEvent *)fbEvent {
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[[fbEvent start_time] doubleValue]];
    return [NSDate dateFromYmdString:[startDate stringYmdWithTimeZone:[NSTimeZone timeZoneWithAbbreviation:timeZonePST]]];
}


@end


@implementation ATFbEvent

@synthesize id_ = _id_;
@synthesize owner = _owner;
@synthesize name = _name;
@synthesize description_ = _description_;
@synthesize start_time = _start_time;
@synthesize end_time = _end_time;
@synthesize location = _location;
@synthesize venue = _venue;
@synthesize privacy = _privacy;
@synthesize updated_time = _updated_time;

- (void)dealloc {
    [_id_ release];
    [_owner release];
    [_name release];
    [_description_ release];
    [_start_time release];
    [_end_time release];
    [_location release];
    [_venue release];
    [_privacy release];
    [_updated_time release];
    [super dealloc];
}


@end
