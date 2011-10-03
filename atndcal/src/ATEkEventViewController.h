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

@interface ATEkEventViewController : TKTableViewController {
  @private
    NSMutableArray *_ekEvents;
    NSString *_titleViewString;
}
@property (nonatomic, retain) NSMutableArray *ekEvents;
@property (nonatomic, retain) NSString *titleViewString;

@end
