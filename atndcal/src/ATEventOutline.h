//
//  ATEventOutline.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ATEvent.h"
#import "ATFbEvent.h"

typedef enum {
    ATEventTypeAtnd = 1,
    ATEventTypeFacebook = 2,
} ATEventType;

@interface ATEventOutlineManager : NSObject {
    
}
+ (ATEventOutlineManager *)sharedATEventOutlineManager;
+ (NSMutableDictionary *)fetchDictionaryForCalendar;
+ (NSMutableArray *)fetchArrayForBookmark;
+ (NSMutableArray *)fetchArrayForAttend;

@end


@interface ATEventOutline : NSObject {
    
    ATEvent *_event;
    ATFbEvent *_fbEvent;
    
    ATEventType _type;
    id _eventObject;
    
    NSString *_managedObjectIdentifier;
    BOOL _isBookmark;
}
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *date;
@property (nonatomic, readonly) NSString *place;

@property (nonatomic, readonly) ATEventType type;
@property (nonatomic, readonly) id eventObject;
@property (nonatomic, readonly) BOOL isOver;

@property (nonatomic, copy) NSString *managedObjectIdentifier;

@property BOOL isBookmark;

- (void)setEventObject:(NSString *)eventObject type:(ATEventType)type;

@end
