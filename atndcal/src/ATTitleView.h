//
//  ATTitleView.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ATTitleView : UIView {
    UILabel *_titleLabel;
}
@property (nonatomic, retain) UILabel *titleLabel;

- (void)setTitle:(NSString *)text;

@end
