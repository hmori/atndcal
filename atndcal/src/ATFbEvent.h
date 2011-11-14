#import <Foundation/Foundation.h>

#import "NSDate+ATCategory.h"

typedef enum {
    ATFbEventDateStart,
    ATFbEventDateEnd,
} ATFbEventDate;

@class ATFbEvent;

@interface ATFbEventManager : NSObject {
    
}
+ (ATFbEventManager *)sharedATFbEventManager;
+ (NSArray *)arrayWithJson:(NSString *)jsonString;
+ (ATFbEvent *)fbEventWithFbEventObject:(id)fbEventObject;
+ (NSString *)stringForDispDate:(ATFbEvent *)fbEvent;
+ (NSString *)stringForDispDate:(ATFbEvent *)fbEvent fbEventDate:(ATFbEventDate)fbEventDate;
+ (NSDate *)dateYmdStartTimeFromFbEvent:(ATFbEvent *)fbEvent;
+ (NSString *)stringDivWithFbEvent:(ATFbEvent *)fbEvent;
@end

@interface ATFbEvent : NSObject {
    id _id_;
    id _owner;
    id _name;
    id _description_;
    id _start_time;
    id _end_time;
    id _location;
    id _venue;
    id _privacy;
    id _updated_time;
}
@property (nonatomic, copy) id id_;
@property (nonatomic, copy) id owner;
@property (nonatomic, copy) id name;
@property (nonatomic, copy) id description_;
@property (nonatomic, copy) id start_time;
@property (nonatomic, copy) id end_time;
@property (nonatomic, copy) id location;
@property (nonatomic, copy) id venue;
@property (nonatomic, copy) id privacy;
@property (nonatomic, copy) id updated_time;

@end
