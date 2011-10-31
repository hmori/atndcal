//
//  ATSettingMenuViewController.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TapkuLibrary/TapkuLibrary.h>
#import "ATLabelTextFieldCell.h"

typedef enum {
    ATSettingMenuSectionAtnd,
    ATSettingMenuSectionFacebook,
    ATSettingMenuSectionEvernote,
    ATSettingMenuSectionAuto,
    ATSettingMenuSectionReset,
} ATSettingMenuSection;


@interface ATSettingMenuViewController : TKTableViewController {
  @private
    NSMutableArray *_sectionItems;
    ATLabelTextFieldCell *_usernameCell;
    UITableViewCell *_requestDaysCountCell;
    UITableViewCell *_facebookLoginCell;
    UITableViewCell *_facebookLogoutCell;
    UITableViewCell *_evernoteCell;
    UITableViewCell *_requestAutoLoadingCell;
    TKButtonCell *_dataResetCell;
}

- (void)doneAction:(id)sender;
- (void)fbLoginAction:(id)sender;
- (void)fbLogoutAction:(id)sender;
- (void)clearDataAction:(id)sender;

@end
