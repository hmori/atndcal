//
//  ATProfileViewController.h
//  atndcal
//
//  Created by Mori Hidetoshi on 11/10/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATTableViewController.h"

@class ATProfileLabelView;

@interface ATProfileViewController : ATTableViewController {
  @private
    NSString *_userId;
    NSString *_twitterId;
    
    NSMutableArray *_ownerEventsArray;
    NSMutableArray *_userEventsArray;
    
    ATProfileLabelView *_profileLabelView;
}
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, retain) NSMutableArray *ownerEventsArray;
@property (nonatomic, retain) NSMutableArray *userEventsArray;

- (void)reloadAction:(id)sender;

@end
