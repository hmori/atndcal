//
//  ATEventAttendViewController.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATEventListViewController.h"

@interface ATEventAttendViewController : ATEventListViewController {
  @private
    NSMutableArray *_eventArray;
}

- (void)reloadAction:(id)sender;

@end
