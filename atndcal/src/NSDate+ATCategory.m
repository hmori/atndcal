//
//  NSDate+ATCategory.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDate+ATCategory.h"
#import <TapkuLibrary/TapkuLibrary.h>

@implementation NSDate (ATCategory)

+ (NSDate *)dateForAtndDateString:(NSString *)dateString {
    NSDate *date = nil;
    if (dateString && (NSNull *)dateString != [NSNull null] && dateString.length >= 19) {
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        date = [formatter dateFromString:[dateString substringWithRange:NSMakeRange(0, 19)]];
    }
	return date;
}

+ (NSDate *)dateConvertFromPstDate:(NSDate *)sourceDate {
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = sourceGMTOffset - destinationGMTOffset;
    
    return [[[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate] autorelease];
}

/*
+ (NSDate *)dateForPstTimeInterval:(NSTimeInterval)secs {
    NSDate *sourceDate = [NSDate dateWithTimeIntervalSince1970:secs];

    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    LOG(@"interval=%d", interval);
    
    return [[[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate] autorelease];
}
*/

+ (NSDate *)dateForRssItemPubDateString:(NSString *)dateString {
    NSDate *date = nil;
    if (dateString && (NSNull *)dateString != [NSNull null]) {
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
        date = [formatter dateFromString:dateString];
    }
	return date;
}

+ (NSDate *)dateFromYmdString:(NSString *)ymd {
    return [NSDate dateFromYmdString:ymd timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
}

+ (NSDate *)dateFromYmdString:(NSString *)ymd timeZone:(NSTimeZone *)timeZone {
    NSDate *date = nil;
    if (ymd && ymd.length >= 8) {
        TKDateInformation info;
        info.hour = 0;
        info.minute = 0;
        info.second = 0;
        info.weekday = 0;
        info.year = [[ymd substringWithRange:NSMakeRange(0, 4)] intValue];
        info.month = [[ymd substringWithRange:NSMakeRange(4, 2)] intValue];
        info.day = [[ymd substringWithRange:NSMakeRange(6, 2)] intValue];
        date = [NSDate dateFromDateInformation:info timeZone:timeZone];
    }
    return date;
}

- (NSString *)stringYmd {
    return [self stringYmdWithTimeZone:nil];
//    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
//    [dateFormatter setLocale:[NSLocale currentLocale]];
//	[dateFormatter setDateFormat:@"yyyyMMdd"];
//    NSString *ymd = [dateFormatter stringFromDate:self];
//    return ymd;
}

- (NSString *)stringYmdWithTimeZone:(NSTimeZone *)tz {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    if (tz) {
        [dateFormatter setTimeZone:tz];
    }
    [dateFormatter setLocale:[NSLocale currentLocale]];
	[dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *ymd = [dateFormatter stringFromDate:self];
    return ymd;
}

//- (NSString *)stringYmdForFacebook {
//    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
//    [dateFormatter setLocale:[NSLocale currentLocale]];
//	[dateFormatter setDateFormat:@"yyyyMMdd"];
//    NSString *ymd = [dateFormatter stringFromDate:self];
//    return ymd;
//}

- (NSString *)stringForDispDateYmw {
    return [self stringForDispDateYmwWithTimeZone:nil];
}

- (NSString *)stringForDispDateYmwWithTimeZone:(NSTimeZone *)tz {
    NSString *string = nil;
    if (self) {
        NSDateFormatter *ymDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [ymDateFormatter setLocale:[NSLocale currentLocale]];
        if (tz) {
            [ymDateFormatter setTimeZone:tz];
        }
        [ymDateFormatter setDateFormat:@"MM月dd日"];
        NSCalendar *cal = [NSCalendar currentCalendar];
        if (tz) {
            [cal setTimeZone:tz];
        }
        NSDateComponents* components = [cal components:NSWeekdayCalendarUnit 
                                              fromDate:self];
        NSString* wdayjp = [self weekdayJp:[components weekday]];
        string = [NSString stringWithFormat:@"%@(%@)", [ymDateFormatter stringFromDate:self], wdayjp];
    }
    return string;
}

- (NSString *)stringForDispDateHm {
    return [self stringForDispDateHmWithTimeZone:nil];
}

- (NSString *)stringForDispDateHmWithTimeZone:(NSTimeZone *)tz {
    NSString *string = nil;
    if (self) {
        NSDateFormatter *hmDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [hmDateFormatter setLocale:[NSLocale currentLocale]];
        if (tz) {
            [hmDateFormatter setTimeZone:tz];
        }
        [hmDateFormatter setDateFormat:@"HH:mm"];
        string = [hmDateFormatter stringFromDate:self];
    }
    return string;
}

- (NSString*)weekdayJp:(NSInteger)weekday {
    switch (weekday) {
        case 1:    return @"日";
        case 2:    return @"月";
        case 3:    return @"火";
        case 4:    return @"水";
        case 5:    return @"木";
        case 6:    return @"金";
        case 7:    return @"土";
        default:;
    }
    return @"";
}



@end
