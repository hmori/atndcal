//
//  NSManagedObjectContext+ATCategory.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*
#import "NSManagedObjectContext+ATCategory.h"

NSString * const NSManagedObjectContextThreadKey = @"NSManagedObjectContextThreadKey";

@interface NSManagedObjectContext ()
- (void)managedObjectContextDidSave:(NSNotification*)notification;
@end

@implementation NSManagedObjectContext (ATCategory)

+ (NSManagedObjectContext *)managedObjectContextForThread:(NSThread *)thread {
    NSMutableDictionary *threadDictionary = [thread threadDictionary];
    NSManagedObjectContext *context = [threadDictionary objectForKey:NSManagedObjectContextThreadKey];
    
    if (!context) {
        id appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *mainContext = [appDelegate managedObjectContext];
        
        if ([[NSThread currentThread] isMainThread]) {
            context = mainContext;
        } else {
            context = [[[NSManagedObjectContext alloc] init] autorelease];
            [context setPersistentStoreCoordinator:[mainContext persistentStoreCoordinator]];
        }
        
        [threadDictionary setObject:context forKey:NSManagedObjectContextThreadKey];
    }
    
    return context;
}

+ (NSManagedObjectContext *)managedObjectContextForCurrentThread {
    return [NSManagedObjectContext managedObjectContextForThread:[NSThread currentThread]];
}

+ (NSManagedObjectContext *)managedObjectContextForMainThread {
    return [NSManagedObjectContext managedObjectContextForThread:[NSThread mainThread]];
}

+ (BOOL)save:(NSError **)error {
    NSManagedObjectContext *context = [NSManagedObjectContext managedObjectContextForCurrentThread];
    BOOL isMainThread = [[NSThread currentThread] isMainThread];
    
    if (!isMainThread) {
        [[NSNotificationCenter defaultCenter] addObserver:context
                                                 selector:@selector(managedObjectContextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:context];
    }
    
    BOOL result = [context save:error];
    
    if (!isMainThread) {
        [[NSNotificationCenter defaultCenter] removeObserver:context
                                                        name:NSManagedObjectContextDidSaveNotification 
                                                      object:context];
    }
    
    return result;
}

- (void)managedObjectContextDidSave:(NSNotification *)notification {
    NSManagedObjectContext *context = [NSManagedObjectContext managedObjectContextForMainThread];
    
    [context performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                              withObject:notification
                           waitUntilDone:YES];
}

@end
*/