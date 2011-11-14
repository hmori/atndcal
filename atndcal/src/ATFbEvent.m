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

static NSString * const kStreet = @"street";
static NSString * const kLatitude = @"latitude";
static NSString * const kLongitude = @"longitude";

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

+ (NSString *)stringDivWithFbEvent:(ATFbEvent *)fbEvent {
    
    static NSString *hTitleFormat = @""
    "<h1>%@</h1>";
    
    static NSString *trDateFormat = @""
    "<tr>"
    "<td width='55px' style='background-color:#4682B4;color:#ffffff;'>"
    "日時"
    "</td>"
    "<td style='background-color:#ffffff;color:#4682B4;'>"
    "%@"
    "</td>"
    "</tr>";

    static NSString *trPlaceFormat = @""
    "<tr>"
    "<td style='background-color:#4682B4;color:#ffffff;'>"
    "会場"
    "</td>"
    "<td style='background-color:#ffffff;color:#4682B4;'>"
    "<a href='http://www.google.co.jp/maps?%@'>%@ (%@)</a>"
    "</td>"
    "</tr>";

    static NSString *trWebFormat = @""
    "<tr>"
    "<td style='background-color:#4682B4;color:#ffffff;'>"
    "Web"
    "</td>"
    "<td style='background-color:#ffffff;color:#4682B4;'>"
    "<a href='http://www.facebook.com/event.php?eid=%@'>http://www.facebook.com/event.php?eid=%@</a>"
    "</td>"
    "</tr>";
    
    static NSString *trOwnerFormat = @""
    "<tr>"
    "<td style='background-color:#4682B4;color:#ffffff;'>"
    "主催者"
    "</td>"
    "<td style='background-color:#ffffff;color:#4682B4;'>"
    "%@"
    "</td>"
    "</tr>";

    static NSString *trDescriptionFormat = @""
    "<tr>"
    "<td style='background-color:#4682B4;color:#ffffff;'>"
    "詳細:"
    "</td>"
    "<td style='background-color:#ffffff;color:#4682B4;'>"
    "%@"
    "</td>"
    "</tr>";
    
    
    NSMutableString *divString = [NSMutableString stringWithCapacity:0];
    [divString appendString:@"<div style='margin:5px;padding:5px;border:1px solid #f0f0f0;background:#f5f5f5;-webkit-border-radius:5px;'>"];
    if (fbEvent.name && (NSNull *)fbEvent.name != [NSNull null]) {
        [divString appendFormat:hTitleFormat, fbEvent.name];
    }
    [divString appendString:@"<hr/><table border='0' cellspacing='1' style='background-color:#4682B4;'><tbody>"];

    NSString *dispDate = [ATFbEventManager stringForDispDate:fbEvent];
    if (dispDate) {
        [divString appendFormat:trDateFormat, dispDate];
    }

    NSString *location = nil;
    if (fbEvent.location && [fbEvent.location length] > 0) {
        location = fbEvent.location;
    }
    NSString *street = nil;
    if (fbEvent.venue && [fbEvent.venue isKindOfClass:NSDictionary.class] &&
        [fbEvent.venue objectForKey:kStreet] && [[fbEvent.venue objectForKey:kStreet] length] > 0) {
        street = [fbEvent.venue objectForKey:kStreet];
    }
    NSString *googleMapParam = nil;
    if (fbEvent.venue && [fbEvent.venue isKindOfClass:NSDictionary.class] &&
        [fbEvent.venue objectForKey:kLatitude] && [fbEvent.venue objectForKey:kLongitude]) {
        googleMapParam = [NSString stringWithFormat:@"q=%@,%@&z=17", 
                          [fbEvent.venue objectForKey:kLatitude], 
                          [fbEvent.venue objectForKey:kLongitude]];
    } else if (street) {
        googleMapParam = [NSString stringWithFormat:@"q=%@&z=17", street];
    } else {
        googleMapParam = [NSString stringWithFormat:@"q=%@&z=17", location];
    }
    if (location || street) {
        [divString appendFormat:trPlaceFormat, [googleMapParam escapeHTML], location, street];
    }

    if (fbEvent.id_ && (NSNull *)fbEvent.id_ != [NSNull null]) {
        [divString appendFormat:trWebFormat, fbEvent.id_, fbEvent.id_];
    }
    
    if (fbEvent.owner && (NSNull *)fbEvent.owner != [NSNull null]) {
        [divString appendFormat:trOwnerFormat, fbEvent.owner];
    }
    
    NSString *dispDescription = fbEvent.description_;
    if (dispDescription) {
        [divString appendFormat:trDescriptionFormat, dispDescription];
    }

    [divString appendString:@"</tbody></table></div>"];

    return divString;
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
