//
//  ATEventForDate.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ATCoreDataManager.h"
#import "ATEventOutline.h"

@interface ATEventForDateManager : ATCoreDataManager {
    
}
+ (ATEventForDateManager *)sharedATEventForDateManager;
- (NSArray *)arrayEventForDateWithEventArray:(NSArray *)eventArray type:(ATEventType)type date:(NSDate *)date;
- (NSArray *)fetchAllData;
- (NSInteger)deleteAll;

@end

@interface ATEventForDate : NSManagedObject {
    
}
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) id eventObject;
@property (nonatomic, retain) NSDate *createAt;

@end
