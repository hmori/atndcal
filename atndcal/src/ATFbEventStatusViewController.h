//
//  ATFbEventStatusViewController.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ATTableViewController.h"
#import "ATFbEventStatus.h"

@interface ATFbEventStatusViewController : ATTableViewController {
  @private
    ATFbEventStatus *_eventStatus;
    NSInteger _selectedIndex;
}
@property (nonatomic, retain) ATFbEventStatus *eventStatus;

@end
