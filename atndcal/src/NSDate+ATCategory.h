#import <Foundation/Foundation.h>


@interface NSDate (ATCategory)

+ (NSDate *)dateForAtndDateString:(NSString *)dateString;
+ (NSDate *)dateConvertFromPstDate:(NSDate *)sourceDate;
+ (NSDate *)dateForRssItemPubDateString:(NSString *)dateString;
+ (NSDate *)dateFromYmdString:(NSString *)ymd;
+ (NSDate *)dateFromYmdString:(NSString *)ymd timeZone:(NSTimeZone *)timeZone;

- (NSString *)stringYmd;
- (NSString *)stringYmdWithTimeZone:(NSTimeZone *)tz;
- (NSString *)stringForDispDateYmw;
- (NSString *)stringForDispDateYmwWithTimeZone:(NSTimeZone *)tz;
- (NSString *)stringForDispDateHm;
- (NSString *)stringForDispDateHmWithTimeZone:(NSTimeZone *)tz;
- (NSString*)weekdayJp:(NSInteger)weekday;

@end
