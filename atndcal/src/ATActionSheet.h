//
//  ATActionSheet.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ATActionSheet;
typedef void (^ATActionSheetIndexBlock)(ATActionSheet *actionSheet, NSInteger index);

@interface ATActionSheet : UIActionSheet <UIActionSheetDelegate> {
  @private
    void (^_cancelCallbackBlock)(ATActionSheet *);
    void (^_willPresentCallbackBlock)(ATActionSheet *);
    void (^_didPresentCallbackBlock)(ATActionSheet *);
    void (^_willDismissCallbackBlock)(ATActionSheet *, NSInteger);
    void (^_didDismissCallbackBlock)(ATActionSheet *, NSInteger);

    NSMutableArray *_buttonCallbacks;
}
@property (nonatomic, retain) void (^cancelCallbackBlock)(ATActionSheet *);
@property (nonatomic, retain) void (^willPresentCallbackBlock)(ATActionSheet *);
@property (nonatomic, retain) void (^didPresentCallbackBlock)(ATActionSheet *);
@property (nonatomic, retain) void (^willDismissCallbackBlock)(ATActionSheet *, NSInteger);
@property (nonatomic, retain) void (^didDismissCallbackBlock)(ATActionSheet *, NSInteger);

- (id)initWithTitle:(NSString *)title;
- (void)addCancelButtonWithTitle:(NSString *)title callback:(ATActionSheetIndexBlock)callback;
- (void)addDestructiveButtonWithTitle:(NSString *)title callback:(ATActionSheetIndexBlock)callback;
- (void)addButtonWithTitle:(NSString *)title callback:(ATActionSheetIndexBlock)callback;

@end