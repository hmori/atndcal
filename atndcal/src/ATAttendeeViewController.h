//
//  ATAttendeeViewController.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATTableViewController.h"
#import "ATEvent.h"

@interface ATAttendeeViewController : ATTableViewController {
  @private
    ATEvent *_event;
    NSMutableArray *_userArray;
    NSMutableDictionary *_twitterImageUrlDictionary;
}
@property (nonatomic, retain) ATEvent *event;

- (void)reloadAction:(id)sender;

@end
