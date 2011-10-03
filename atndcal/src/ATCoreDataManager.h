//
//  ATCoreDataManager.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseCoreDataManager.h"

@interface ATCoreDataManager : BaseCoreDataManager {
    
}
- (NSManagedObject *)new:(NSString *)entity;
- (NSInteger)deleteFrom:(NSString *)entity identifier:(NSString *)identifier;
- (NSInteger)truncate;

@end
