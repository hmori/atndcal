#import "ATEventLabelTextCell.h"


@implementation ATEventLabelTextCell
@synthesize widthLabel = _widthLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.label.textAlignment = UITextAlignmentLeft;
        self.label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.label.backgroundColor = [UIColor clearColor];

        self.field.numberOfLines = INT_MAX;
        self.field.font = [UIFont systemFontOfSize:14.0f];
        self.field.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.field.backgroundColor = [UIColor clearColor];

        _widthLabel = 45.0f;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
	
    CGRect r = CGRectInset(self.contentView.bounds, 8.0f, 8.0f);
	r.size.width = _widthLabel;
	_label.frame = r;

	
    r = CGRectInset(self.contentView.bounds, 8.0f, 8.0f);
	r.origin.x += self.label.frame.size.width + 6.0f;
	r.size.width -= self.label.frame.size.width + 6.0f;
	_field.frame = r;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
    [super dealloc];
}

@end
