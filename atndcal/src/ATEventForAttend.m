#import "ATEventForAttend.h"

#import "ObjectSingleton.h"

@implementation ATEventForAttendManager

OBJECT_SINGLETON_TEMPLATE(ATEventForAttendManager, sharedATEventForAttendManager)

static NSString *EventForAttend = @"EventForAttend";

- (NSString *)entityName {
    return EventForAttend;
}

- (NSError *)saveWithEventArray:(NSArray *)eventArray {
    NSError *error = nil;
    
    NSDate *createAt = [NSDate date];
    for (id eventObject in eventArray) {
        POOL_START;
        ATEventForAttend *eventForBookmark = [(ATEventForAttend *)[self new:EventForAttend] autorelease];
        eventForBookmark.eventObject = eventObject;
        eventForBookmark.createAt = createAt;
        NSError *e = [self save];
        if (!error) {
            error = e;
        }
        POOL_END;
    }
    return error;
}

- (NSError *)saveWithEventObject:(id)eventObject {
    ATEventForAttend *eventForBookmark = [(ATEventForAttend *)[self new:EventForAttend] autorelease];
    eventForBookmark.eventObject = eventObject;
    eventForBookmark.createAt = [NSDate date];
    return [self save];
}

- (NSArray *)fetchAllData {
    return [self select:EventForAttend where:nil sortKey:@"createAt" ascending:NO];
}

- (NSInteger)removeObjectAtIdentifier:(NSString *)identifier {
    NSInteger count = [self deleteFrom:EventForAttend identifier:identifier];
    if (count > 0) {
        [self save];
    }
    return count;
}

@end


@implementation ATEventForAttend
@dynamic identifier;
@dynamic eventObject;
@dynamic createAt;
@end
