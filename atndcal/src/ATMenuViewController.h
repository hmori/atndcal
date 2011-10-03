//
//  ATMenuViewController.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ATTableViewController.h"

@interface ATMenuViewController : ATTableViewController {
    
}
- (void)closeAction:(id)sender;
- (void)settingAction:(id)sender;
- (void)fbLoginAction:(id)sender;
- (void)fbLogoutAction:(id)sender;

@end
