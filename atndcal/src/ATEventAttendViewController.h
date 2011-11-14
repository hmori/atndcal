#import <UIKit/UIKit.h>
#import "ATEventListViewController.h"

@interface ATEventAttendViewController : ATEventListViewController {
  @private
    NSMutableArray *_eventArray;
}

- (void)reloadAction:(id)sender;

@end
