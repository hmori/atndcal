//
//  ATLabelTextFieldCell.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATLabelTextFieldCell : UITableViewCell <UITextFieldDelegate> { //TKLabelTextFieldCell {
    CGFloat _widthLabel;
    UITextField *_field;

}
@property CGFloat widthLabel;
@property (nonatomic, retain) UITextField *field;

@end
