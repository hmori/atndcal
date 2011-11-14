#import <UIKit/UIKit.h>

#import "ATTableViewController.h"

@class ATMailComposer;

@interface ATSettingInfoViewController : ATTableViewController {
  @private
    ATMailComposer *_mailComposer;
}

- (void)contactAction:(id)sender;

@end
