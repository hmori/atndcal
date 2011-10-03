//
//  ATEventBookmarkViewController.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATEventListViewController.h"

@interface ATEventBookmarkViewController : ATEventListViewController {
    UIBarButtonItem *_editActionButtonItem;
    UIBarButtonItem *_doneActionButtonItem;
}

- (void)editAction:(id)sender;
- (void)doneAction:(id)sender;

@end
