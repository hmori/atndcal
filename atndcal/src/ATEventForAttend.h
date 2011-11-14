#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>
#import "ATCoreDataManager.h"

@interface ATEventForAttendManager : ATCoreDataManager {
    
}
+ (ATEventForAttendManager *)sharedATEventForAttendManager;
- (NSError *)saveWithEventArray:(NSArray *)eventArray;
- (NSError *)saveWithEventObject:(id)eventObject;
- (NSArray *)fetchAllData;
- (NSInteger)removeObjectAtIdentifier:(NSString *)identifier;

@end


@interface ATEventForAttend : NSManagedObject {
    
}
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, retain) id eventObject;
@property (nonatomic, retain) NSDate *createAt;

@end
