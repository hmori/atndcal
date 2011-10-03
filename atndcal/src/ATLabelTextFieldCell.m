//
//  ATLabelTextFieldCell.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATLabelTextFieldCell.h"

@implementation ATLabelTextFieldCell
@synthesize widthLabel = _widthLabel;
@synthesize field = _field;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
	if((self=[super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        _widthLabel = 90.0f;
        _field = [[UITextField alloc] initWithFrame:CGRectZero];
        _field.font = [UIFont systemFontOfSize:17.0];
        _field.textColor = HEXCOLOR(0x44608CFF);
        _field.delegate = self;
        _field.clearButtonMode = UITextFieldViewModeWhileEditing;
        _field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _field.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self.contentView addSubview:_field];
    }
    return self;
}

- (void)dealloc {
    [_field release];
    [super dealloc];
}

- (void) layoutSubviews {
    [super layoutSubviews];
	CGRect r = CGRectInset(self.contentView.bounds, 8, 8);
	r.size.width = _widthLabel;
	self.textLabel.frame = r;

	r = CGRectInset(self.contentView.bounds, 8, 8);
	r.origin.x += self.textLabel.frame.size.width + 12;
	r.size.width -= self.textLabel.frame.size.width + 12;
	self.field.frame = r;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    LOG_CURRENT_METHOD;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    LOG_CURRENT_METHOD;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    LOG_CURRENT_METHOD;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    LOG_CURRENT_METHOD;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    LOG_CURRENT_METHOD;
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    LOG_CURRENT_METHOD;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    LOG_CURRENT_METHOD;
    [_field resignFirstResponder];
    return YES;
}


@end
