#import <UIKit/UIKit.h>
#import <TapkuLibrary/TapkuLibrary.h>
#import "ATLabelTextFieldCell.h"

@class ATWaitingView;

@interface ATSettingEvernoteViewController : TKTableViewController {
  @private
    ATLabelTextFieldCell *_usernameCell;
    ATLabelTextFieldCell *_passwordCell;
    
    ATWaitingView *_waitingView;
}

@end
