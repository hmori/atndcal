#import <Foundation/Foundation.h>
#import "BaseCoreDataManager.h"

@interface ATCoreDataManager : BaseCoreDataManager {
    
}
- (NSManagedObject *)new:(NSString *)entity;
- (NSInteger)deleteFrom:(NSString *)entity identifier:(NSString *)identifier;
- (NSInteger)truncate;

@end
