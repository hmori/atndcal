#import "ATEventForDate.h"
#import "ObjectSingleton.h"

@implementation ATEventForDateManager

OBJECT_SINGLETON_TEMPLATE(ATEventForDateManager, sharedATEventForDateManager)

static NSString *EventForDate = @"EventForDate";

- (NSString *)entityName {
    return EventForDate;
}

- (NSArray *)arrayEventForDateWithEventArray:(NSArray *)eventArray type:(ATEventType)type date:(NSDate *)date {
    LOG_CURRENT_METHOD;
    
    NSMutableArray *arrayEventForDate = [NSMutableArray arrayWithCapacity:0];
    NSDate *createAt = [NSDate date];
    for (id eventObject in eventArray) {
        POOL_START;
        ATEventForDate *eventForDate = [(ATEventForDate *)[self new:EventForDate] autorelease];
        eventForDate.type = [NSNumber numberWithInt:type];
        eventForDate.date = date;
        eventForDate.eventObject = eventObject;
        eventForDate.createAt = createAt;
        [arrayEventForDate addObject:eventForDate];
        POOL_END;
    }
    return arrayEventForDate;
}

- (NSArray *)fetchAllData {
    return [self select:EventForDate where:nil];
}

- (NSInteger)deleteAll {
    NSInteger count = [self deleteAll:[self entityName]];
    return count;
}

@end


@implementation ATEventForDate
@dynamic identifier;
@dynamic type;
@dynamic date;
@dynamic eventObject;
@dynamic createAt;
@end
