#import "ATCoreDataManager.h"

@implementation ATCoreDataManager

#pragma mark - Overwride BaseCoreDataManager

- (NSString *)modelName {
    static NSString *modelName = @"at";
    return modelName;
}

- (NSString *)entityName {
    static NSString *entityName = @"core";
    return entityName;
}

#pragma mark - Public

- (NSManagedObject *)new:(NSString *)entity {
    NSManagedObject *newManagedObject = [super new:entity];
    
    if ([newManagedObject respondsToSelector:@selector(setIdentifier:)]) {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        NSString *identifier = (NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        [newManagedObject performSelector:@selector(setIdentifier:) withObject:identifier];
        [identifier release];
    }
	return newManagedObject;
}

- (NSInteger)deleteFrom:(NSString *)entity identifier:(NSString *)identifier {
    static NSString *wherePhraseFormat = @"identifier='%@'";
    NSInteger count = 0;
	NSArray *arr = [self select:entity 
                          where:[NSString stringWithFormat:wherePhraseFormat, identifier]];
    for (NSManagedObject *object in arr) {
        [self delete:object];
        count++;
    }
	return count;
}

- (NSInteger)truncate {
    NSInteger count = [self deleteAll:[self entityName]];
    if (count > 0) {
        [self save];
    }
    return count;
}


@end
