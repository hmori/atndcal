//
//  ATAtndEventDetailViewController.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ATEventDetailViewController.h"

@interface ATAtndEventDetailViewController : ATEventDetailViewController {
  @private
    ATEvent *_event;
    NSArray *_commentItems;
    
    NSMutableArray *_itemsInSection0;
    NSMutableArray *_itemsInSection1;
    NSMutableArray *_itemsInSection2;
    NSMutableArray *_itemsInSection3;
    NSMutableArray *_itemsInSection4;
    NSMutableArray *_itemsInSection5;
    NSMutableArray *_itemsInSection6;
    
    BOOL _isContinueDescription;
}

- (void)otherAction:(id)sender;
- (void)dateAction:(id)sender;
- (void)placeAction:(id)sender;
- (void)addressAction:(id)sender;
- (void)mapAction:(id)sender;
- (void)urlAction:(id)sender;
- (void)textAction:(id)sender text:(NSString *)text;
- (void)entryAction:(id)sender;

- (void)reloadCommentAction:(id)sender;
- (void)reloadLwwsAction:(id)sender;

@end
