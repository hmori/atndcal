//
//  ATCalendarTableViewController.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/07/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TapkuLibrary/TapkuLibrary.h>
#import "ATCalendarTitleView.h"
#import "ATWordSelectViewCotroller.h"

@interface ATCalendarTableViewController : TKCalendarMonthTableViewController <ATCalendarTitleViewDelegate, ATWordSelectDelegate> {

  @private
    NSMutableArray *_dataArray; 
	NSMutableDictionary *_dataDictionary;
    
    NSMutableArray *_eventArray;
    
    NSDate *_startDate;
    NSDate *_lastDate;

    ATCalendarTitleView *_titleView;
    UIImageView *_shadowView;
    
    NSString *_keyword;
    NSString *_keyword_or;
    
    BOOL _isAutoLoading;
    
    NSUInteger _countLoading;
    BOOL _isZoom;
    UIToolbar *_customRightBar;
    UIBarButtonItem *_reloadButtonItem;
    UIBarButtonItem *_stopButtonItem;
    UIBarButtonItem *_zoominButtonItem;
    UIBarButtonItem *_zoomoutButtonItem;
    
}

- (void)zoominAction:(id)sender;
- (void)zoomoutAction:(id)sender;
- (void)reloadAction:(id)sender;
- (void)stopAction:(id)sender;
- (void)otherAction:(id)sender;
- (void)resetData;

@end
