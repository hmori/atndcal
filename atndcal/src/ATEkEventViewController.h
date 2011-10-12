//
//  ATEkEventViewController.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ATTableViewController.h"
#import <TapkuLibrary/TapkuLibrary.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface ATEkEventViewController : TKTableViewController <EKEventEditViewDelegate> {
  @private
    NSMutableArray *_ekEvents;
    NSString *_titleViewString;
    
    //EventKit
	EKEventStore *_eventStore;
	EKCalendar *_defaultCalendar;
}
@property (nonatomic, retain) NSMutableArray *ekEvents;
@property (nonatomic, retain) NSString *titleViewString;

@property (nonatomic, retain) EKEventStore *eventStore;
@property (nonatomic, retain) EKCalendar *defaultCalendar;

@end
