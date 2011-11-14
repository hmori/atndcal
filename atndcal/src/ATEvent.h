#import <Foundation/Foundation.h>
#import "NSDate+ATCategory.h"

typedef enum {
    ATEventDateStart,
    ATEventDateEnd,
} ATEventDate;

@class ATEvent;

@interface ATEventManager : NSObject {

}
+ (ATEventManager *)sharedATEventManager;
+ (NSDictionary *)dictionaryWithJson:(NSString *)jsonString;
+ (ATEvent *)eventWithEventObject:(id)eventObject;
+ (NSString *)stringForDispDescription:(ATEvent *)event;
+ (NSString *)stringForDispCapacity:(ATEvent *)event;
+ (NSString *)stringForDispDate:(ATEvent *)event;
+ (NSString *)stringForDispDate:(ATEvent *)event eventDate:(ATEventDate)eventDate;
+ (NSString *)stringDivWithEvent:(ATEvent *)event;
@end


@interface ATEvent : NSObject {
    id _event_id;
    id _title;
    id _catch_;
    id _description_;
    id _event_url;
    id _started_at;
    id _ended_at;
    id _url;
    id _limit;
    id _address;
    id _place;
    id _lat;
    id _lon;
    id _owner_id;
    id _owner_nickname;
    id _owner_twitter_id;
    id _accepted;
    id _waiting;
    id _updated_at;
}

@property (nonatomic, retain) id event_id;
@property (nonatomic, retain) id title;
@property (nonatomic, retain) id catch_;
@property (nonatomic, retain) id description_;
@property (nonatomic, retain) id event_url;
@property (nonatomic, retain) id started_at;
@property (nonatomic, retain) id ended_at;
@property (nonatomic, retain) id url;
@property (nonatomic, retain) id limit;
@property (nonatomic, retain) id address;
@property (nonatomic, retain) id place;
@property (nonatomic, retain) id lat;
@property (nonatomic, retain) id lon;
@property (nonatomic, retain) id owner_id;
@property (nonatomic, retain) id owner_nickname;
@property (nonatomic, retain) id owner_twitter_id;
@property (nonatomic, retain) id accepted;
@property (nonatomic, retain) id waiting;
@property (nonatomic, retain) id updated_at;

@end
