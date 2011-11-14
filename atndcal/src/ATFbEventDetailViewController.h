#import <UIKit/UIKit.h>
#import "ATEventDetailViewController.h"

@class ATFbEventStatus;

@interface ATFbEventDetailViewController : ATEventDetailViewController {
  @private
    ATFbEvent *_event;
    ATFbEventStatus *_eventStatus;
    NSArray *_commentItems;
    NSMutableArray *_itemsInSection0;
    NSMutableArray *_itemsInSection1;
    NSMutableArray *_itemsInSection2;
    NSMutableArray *_itemsInSection3;
    NSMutableArray *_itemsInSection4;
    NSMutableArray *_itemsInSection5;
    
    BOOL _isContinueDescription;
}
- (id)initWithEventObject:(id)eventObject;
- (void)otherAction:(id)sender;
- (void)dateAction:(id)sender;
- (void)placeAction:(id)sender;
- (void)addressAction:(id)sender;
- (void)mapAction:(id)sender;
- (void)textAction:(id)sender text:(NSString *)text;
- (void)reloadRsvpStatusAction:(id)sender;
- (void)reloadLwwsAction:(id)sender;

@end
