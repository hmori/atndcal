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
