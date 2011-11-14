#import "ATEventDateCell.h"


@implementation ATEventDateCell

@synthesize startField = _startField;
@synthesize endField = _endField;

#define widthTitle 60.0f

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        POOL_START;
        self.label.textAlignment = UITextAlignmentLeft;
        self.label.backgroundColor = [UIColor clearColor];
        self.field.backgroundColor = [UIColor clearColor];

        self.startField = [[[UILabel alloc] init] autorelease];
        self.endField = [[[UILabel alloc] init] autorelease];
        _startField.backgroundColor = [UIColor clearColor];
        _endField.backgroundColor = [UIColor clearColor];
        _startField.font = [UIFont systemFontOfSize:13.0f];
        _endField.font = [UIFont systemFontOfSize:13.0f];
        [self.contentView addSubview:_startField];
        [self.contentView addSubview:_endField];
        POOL_END;
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
	
    CGRect r = CGRectInset(self.contentView.bounds, 8.0f, 8.0f);
	r.size.width = 45.0f;
	r.size.height = 30.0f;
	_label.frame = r;

	r = CGRectInset(self.contentView.bounds, 4.0f, 4.0f);
    CGFloat height = r.size.height/2;

	r.origin.x += self.label.frame.size.width + 6.0f;
	r.size.width -= self.label.frame.size.width + 6.0f;
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
