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
