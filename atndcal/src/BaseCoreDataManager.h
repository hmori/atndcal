#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BaseCoreDataManager : NSObject {
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSManagedObjectModel *_managedObjectModel;
}
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;

- (NSArray *)select:(NSString *)entity where:(NSString *)where;
- (NSArray *)select:(NSString *)entity where:(NSString *)where limit:(NSNumber *)limit offset:(NSNumber *)offset;
- (NSArray *)select:(NSString *)entity where:(NSString *)where sortKey:(NSString *)sortKey ascending:(BOOL)ascending;
- (NSArray *)select:(NSString *)entity where:(NSString *)where limit:(NSNumber *)limit offset:(NSNumber *)offset sortKey:(NSString *)sortKey ascending:(BOOL)ascending;

- (NSManagedObject *)new:(NSString *)entity;
- (void)delete:(NSManagedObject *)object;
- (BOOL)deleteFrom:(NSString *)entity atIndexPath:(NSInteger)indexPath;
- (NSInteger)deleteAll:(NSString *)entity;
- (NSError *)save;

- (NSManagedObjectContext *)managedObjectContext;
- (NSManagedObjectContext *)managedObjectContextForThread:(NSThread *)thread;
- (NSString *)modelName;

@end
