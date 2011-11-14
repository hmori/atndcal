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
