#import "ATProfileLabelView.h"
#import "ATCommon.h"

@implementation ATProfileLabelView
@synthesize imageView = _imageView;
@synthesize label = _label;
@synthesize imageUrl = _imageUrl;

static NSString * const newImage = NewImageCenterImage;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        UIView *shadowView = [[[UIView alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 48.0f, 48.0f)] autorelease];
        shadowView.backgroundColor = [UIColor whiteColor];
        
        shadowView.layer.cornerRadius = 8.0f;
        shadowView.layer.shadowOpacity = 0.5f;
        shadowView.layer.shadowRadius = 2.0f;
        shadowView.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        
        self.imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 48.0f, 48.0f)] autorelease];
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 8.0f;
        
        [shadowView addSubview:_imageView];
        
        self.label = [[[UILabel alloc] initWithFrame:CGRectMake(90.0f, 30.0f, 230.0f, 30.0f)] autorelease];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UIFont boldSystemFontOfSize:17.0f];
        _label.shadowColor = [UIColor whiteColor];
        _label.shadowOffset = CGSizeMake(_label.shadowOffset.width, 
                                                -_label.shadowOffset.height);
        [self addSubview:shadowView];
        [self addSubview:_label];
        

        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.contentMode = UIViewContentModeCenter;
        _indicatorView.userInteractionEnabled = NO;
        _indicatorView.center = _imageView.center;
        [_indicatorView startAnimating];
        
        [_imageView addSubview:_indicatorView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(newImageRetrieved) 
                                                     name:newImage 
                                                   object:nil];
        

    }
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_imageView release];
    [_indicatorView release];
    [_label release];
    [_imageUrl release];
    [super dealloc];
}

#pragma mark - setter

- (void)setImageUrl:(NSString *)imageUrl {
    LOG_CURRENT_METHOD;
    if (_imageUrl != imageUrl) {
        [_imageUrl release];
        _imageUrl = [imageUrl retain];
        
        TKImageCenter *imageCenter = [TKImageCenter sharedImageCenter];
        UIImage *image = [imageCenter imageAtURL:_imageUrl queueIfNeeded:NO];
        if (image) {
            self.imageView.image = image;
            [_indicatorView stopAnimating];
        } else {
            [imageCenter imageAtURL:imageUrl queueIfNeeded:YES];
        }
    }
}

#pragma mark - Public

- (void)stopIndicator {
    [_indicatorView stopAnimating];
}


#pragma mark - Observer

- (void)newImageRetrieved {
    LOG_CURRENT_METHOD;
    UIImage *image = [[TKImageCenter sharedImageCenter] imageAtURL:_imageUrl queueIfNeeded:NO];
    if (image) {
        self.imageView.image = image;
    }
    [_indicatorView stopAnimating];
}

@end
