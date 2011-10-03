//
//  ATEventDateTableViewCell.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATEventDateCell.h"


@implementation ATEventDateCell

@synthesize startField = _startField;
@synthesize endField = _endField;

#define widthTitle 60.0f

static NSString * const startFieldText = @"開始日時";
static NSString * const endFieldText = @"終了日時";


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        POOL_START;
        self.label.textAlignment = UITextAlignmentLeft;

        self.startField = [[[UILabel alloc] init] autorelease];
        self.endField = [[[UILabel alloc] init] autorelease];
        _startField.font = [UIFont systemFontOfSize:13.0];
        _endField.font = [UIFont systemFontOfSize:13.0];
        _startField.text = startFieldText;
        _endField.text = endFieldText;
        [self.contentView addSubview:_startField];
        [self.contentView addSubview:_endField];
        POOL_END;
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
	
    CGRect r = CGRectInset(self.contentView.bounds, 8, 8);
	r.size.width = 45;
	r.size.height = 30;
	_label.frame = r;

	r = CGRectInset(self.contentView.bounds, 4, 4);
    CGFloat height = r.size.height/2;

	r.origin.x += self.label.frame.size.width + 6;
	r.size.width -= self.label.frame.size.width + 6;
    r.size.height -= height;

	_startField.frame = r;
    
    r.origin.y += height;
	_endField.frame = r;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    _startField.textColor = selected ? [UIColor whiteColor] : [UIColor blackColor];
    _endField.textColor = selected ? [UIColor whiteColor] : [UIColor blackColor];
}

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
	[super setHighlighted:highlighted animated:animated];
	_startField.textColor = highlighted ? [UIColor whiteColor] : [UIColor blackColor];
	_endField.textColor = highlighted ? [UIColor whiteColor] : [UIColor blackColor];
}

- (void)dealloc {
    [_startField release];
    [_endField release];
    [super dealloc];
}

@end
