#import <UIKit/UIKit.h>
#import "ATEventListViewController.h"

@interface ATEventBookmarkViewController : ATEventListViewController {
    UIBarButtonItem *_editActionButtonItem;
    UIBarButtonItem *_doneActionButtonItem;
}

- (void)editAction:(id)sender;
- (void)doneAction:(id)sender;

@end
