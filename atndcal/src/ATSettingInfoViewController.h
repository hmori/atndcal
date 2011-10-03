//
//  ATSettingInfoViewController.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ATTableViewController.h"

@class ATMailComposer;

@interface ATSettingInfoViewController : ATTableViewController {
  @private
    ATMailComposer *_mailComposer;
}

- (void)contactAction:(id)sender;

@end
