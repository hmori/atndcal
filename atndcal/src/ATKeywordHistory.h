#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ATCoreDataManager.h"

@interface ATKeywordHistoryManager : ATCoreDataManager {
    
}
+ (ATKeywordHistoryManager *)sharedATKeywordHistoryManager;
- (NSError *)saveKeyword:(NSString *)keyword;
- (NSMutableArray *)fetchReversedKeywords;
@end


@interface ATKeywordHistory : NSManagedObject {
    
}
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, retain) NSDate *createAt;

@end


