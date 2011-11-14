#import "ATLwwsCell.h"

#define xInsetCommentCellForField 8.0f
#define yInsetCommentCellForField 13.0f
#define widthCommentCellForField 298.0f

#define adjustFieldY 38.0f

@implementation ATLwwsCell
@synthesize iconImageView = _iconImageView;
@synthesize pubDateLabel = _pubDateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        POOL_START;
        self.iconImageView = [[[UIImageView alloc] init] autorelease];
        _iconImageView.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:_iconImageView];
        
        self.label.backgroundColor = [UIColor clearColor];
        self.label.font = [UIFont boldSystemFontOfSize:15];
        self.label.textAlignment = UITextAlignmentLeft;
        self.label.textColor = [UIColor blackColor];
        self.pubDateLabel = [[[UILabel alloc] init] autorelease];
        _pubDateLabel.backgroundColor = [UIColor clearColor];
        _pubDateLabel.font = [UIFont systemFontOfSize:13];
        _pubDateLabel.textColor = HEXCOLOR(0x44608CFF);
        [self.contentView addSubview:_pubDateLabel];
        POOL_END;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect ir = CGRectMake(5.0f, 10.0f, 50.0f, 31.0f);
    self.iconImageView.frame = ir;

	CGRect lr = CGRectInset(self.contentView.bounds, xInsetCommentCellForField, yInsetCommentCellForField);
    lr.origin.x += 50.0f;
    lr.origin.y += 5.0f;
    lr.size.height = self.label.font.pointSize + 2.0f;
    self.label.frame = lr;
    
    lr.origin.y += lr.size.height + 2.0f;
    lr.size.height = _pubDateLabel.font.pointSize + 2.0f;
    _pubDateLabel.frame = lr;
    
	CGRect r = CGRectInset(self.contentView.bounds, xInsetCommentCellForField, yInsetCommentCellForField);
    r.origin.y += adjustFieldY;
    r.size.height = CGFLOAT_MAX;
    r = [_field textRectForBounds:r limitedToNumberOfLines:INT_MAX];
	_field.frame = r;
}

- (void)dealloc {
    [_iconImageView release];
    [_pubDateLabel release];
    [super dealloc];
}

#pragma mark - Public

+ (CGFloat)heightCellOfLabelText:(NSString *)text truncate:(BOOL)truncate {
    return [super heightCellOfLabelText:text truncate:truncate] + adjustFieldY + 20.0f;
}

@end
