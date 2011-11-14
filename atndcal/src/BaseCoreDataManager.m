#import "BaseCoreDataManager.h"

@interface BaseCoreDataManager ()
- (NSURL *)applicationDocumentsDirectory;
- (NSString *)modelName;
@end

@implementation BaseCoreDataManager

static NSString * const kATManagedObjectContextThread = @"kATManagedObjectContextThread";

- (void)dealloc {
    [_persistentStoreCoordinator release];
	[_managedObjectModel release];
    [super dealloc];
}

#pragma mark - Public methods

- (NSArray *)select:(NSString *)entity where:(NSString *)where {
	return [self select:entity where:where limit:nil offset:nil];
}

- (NSArray *)select:(NSString *)entity where:(NSString *)where limit:(NSNumber *)limit offset:(NSNumber *)offset {
    return [self select:entity where:where limit:limit offset:offset sortKey:nil ascending:YES];
}

- (NSArray *)select:(NSString *)entity where:(NSString *)where sortKey:(NSString *)sortKey ascending:(BOOL)ascending {
    return [self select:entity where:where limit:nil offset:nil sortKey:sortKey ascending:ascending];
}

- (NSArray *)select:(NSString *)entity where:(NSString *)where limit:(NSNumber *)limit offset:(NSNumber *)offset sortKey:(NSString *)sortKey ascending:(BOOL)ascending {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity 
                                                         inManagedObjectContext:self.managedObjectContext];
	
	if (where != nil && 0<[where length]) {
		[request setPredicate:[NSPredicate predicateWithFormat:where]];
	}
	if (limit != nil) {
		[request setFetchLimit:[limit intValue]];
	}
	if (offset != nil) {
		[request setFetchOffset:[offset intValue]];
	}
	[request setEntity:entityDescription];
    if (sortKey != nil) {
        NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending] autorelease];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }
        
	
	NSError *error = nil;
	NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:request error:&error];
	[request release];
	if (error) {
        LOG(@"executeFetchRequest: failed, %@", [error localizedDescription]);
		return nil;
	}
	return fetchResult;
}

- (NSManagedObject *)new:(NSString *)entity {
	NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:entity 
                                                                      inManagedObjectContext:self.managedObjectContext];
	[newManagedObject retain];
	return newManagedObject;
}

- (void)delete:(NSManagedObject *)object {
	[self.managedObjectContext deleteObject:object];
}

- (BOOL)deleteFrom:(NSString *)entity atIndexPath:(NSInteger)indexPath {
    BOOL ret = NO;
    POOL_START;
	NSArray *arr = [self select:entity 
                          where:nil 
                          limit:[NSNumber numberWithInt:1] 
                         offset:[NSNumber numberWithInt:indexPath]];
	if ([arr count]==1) {
		NSManagedObject *object = [arr objectAtIndex:0];
		[self.managedObjectContext deleteObject:object];
		ret = YES;
	}
    POOL_END;
	return ret;
}

- (NSInteger)deleteAll:(NSString *)entity {
    NSInteger count = 0;
    POOL_START;
	NSArray *array = [self select:entity where:nil];
    for (NSManagedObject *object in array) {
        [self delete:object];
        count++;
    }
    POOL_END;
    return count;
}

- (NSError *)save {
    LOG_CURRENT_METHOD;
    POOL_START;
    NSManagedObjectContext *context = [self managedObjectContext];
    BOOL isMainThread = [[NSThread currentThread] isMainThread];
    
    if (!isMainThread) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(managedObjectContextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:context];
    }
    
    NSError *error = nil;
    if ([context save:&error]) {
        error = nil;
    }

    if (!isMainThread) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSManagedObjectContextDidSaveNotification 
                                                      object:context];
    }
    POOL_END;
    return error;
}

#pragma mark - Notification

- (void)managedObjectContextDidSave:(NSNotification *)notification {
    LOG_CURRENT_METHOD;
    POOL_START;
    NSManagedObjectContext *context = [self managedObjectContextForThread:[NSThread mainThread]];
    [context performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                              withObject:notification
                           waitUntilDone:YES];
    POOL_END;
}


#pragma mark - CoreDataManage

- (NSManagedObjectContext *)managedObjectContext {
    return [self managedObjectContextForThread:[NSThread currentThread]];
}

- (NSManagedObjectContext *)managedObjectContextForThread:(NSThread *)thread {
    NSMutableDictionary *threadDictionary = [thread threadDictionary];
    NSManagedObjectContext *context = [threadDictionary objectForKey:kATManagedObjectContextThread];
    
    if (!context) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator) {
            context = [[[NSManagedObjectContext alloc] init] autorelease];
            [context setPersistentStoreCoordinator:coordinator];
            
            [threadDictionary setObject:context forKey:kATManagedObjectContextThread];
        }
    }
    return context;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:
                       [NSString stringWithFormat:@"%@.sqlite", [self modelName]]];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] 
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                   configuration:nil 
                                                             URL:storeURL 
                                                         options:nil 
                                                           error:&error]) {
        
        LOG(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
	_managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain]; 
    return _managedObjectModel;
}

#pragma mark - Private

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)modelName {
    return @"coredata";
}

@end
