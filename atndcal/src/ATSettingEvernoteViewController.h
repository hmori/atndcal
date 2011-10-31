//
//  ATSettingEvernoteViewController.h
//  atndcal
//
//  Created by Mori Hidetoshi on 11/10/20.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
