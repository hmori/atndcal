//
//  NSDate+ATCategory.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (ATCategory)

+ (NSDate *)dateForAtndDateString:(NSString *)dateString;
//+ (NSDate *)dateForPstTimeInterval:(NSTimeInterval)secs;
+ (NSDate *)dateConvertFromPstDate:(NSDate *)sourceDate;
+ (NSDate *)dateForRssItemPubDateString:(NSString *)dateString;
+ (NSDate *)dateFromYmdString:(NSString *)ymd;
+ (NSDate *)dateFromYmdString:(NSString *)ymd timeZone:(NSTimeZone *)timeZone;
- (NSString *)stringYmd;
- (NSString *)stringYmdWithTimeZone:(NSTimeZone *)tz;
//- (NSString *)stringYmdForFacebook;
- (NSString *)stringForDispDateYmw;
- (NSString *)stringForDispDateYmwWithTimeZone:(NSTimeZone *)tz;
- (NSString *)stringForDispDateHm;
- (NSString *)stringForDispDateHmWithTimeZone:(NSTimeZone *)tz;
- (NSString*)weekdayJp:(NSInteger)weekday;

@end
