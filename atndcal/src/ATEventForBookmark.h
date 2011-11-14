#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ATCoreDataManager.h"
#import "ATEventOutline.h"

@class ATEventForBookmark;

@interface ATEventForBookmarkManager : ATCoreDataManager {
    
}
+ (ATEventForBookmarkManager *)sharedATEventForBookmarkManager;
- (NSError *)saveWithEventObject:(id)eventObject type:(ATEventType)type;
- (NSArray *)fetchAllData;
- (ATEventForBookmark *)fetchEventForBookmarkFromEventId:(NSString *)eventId type:(ATEventType)type;
- (NSInteger)removeObjectAtIdentifier:(NSString *)identifier;

@end


@interface ATEventForBookmark : NSManagedObject {
    
}
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, retain) id eventObject;
@property (nonatomic, retain) NSDate *createAt;

@end
