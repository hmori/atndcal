#import "ATCalendarTitleView.h"


@implementation ATCalendarTitleView
@synthesize delegate = _delegate;
@synthesize dateLabel = _dateLabel;
@synthesize searchBar = _searchBar;
@synthesize blindView = _blindView;
@synthesize date = _date;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        POOL_START;
        self.frame = CGRectMake(0.0f, 0.0f, 170.0f, 44.0f);
        self.dateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(120.0f, 0.0f, 45.0f, 44.0f)] autorelease];

        _dateLabel.textAlignment = UITextAlignmentCenter;
        _dateLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        _dateLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.shadowColor = [UIColor darkGrayColor];
        _dateLabel.shadowOffset = CGSizeMake(0,-1);
        _dateLabel.font = [UIFont boldSystemFontOfSize:21];
        _dateLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_dateLabel];

        
        self.searchBar = [[[UISearchBar alloc] initWithFrame:self.bounds] autorelease];
        _searchBar.delegate = self;
        _searchBar.showsBookmarkButton = YES;
        
        [self addSubview:_searchBar];
        _searchBar.contentMode = UIViewContentModeLeft;
        
        
        CGRect r = [[UIScreen mainScreen] bounds];
        r.origin.y += 64.0f;
        r.size.height -= 64.0f;
        self.blindView = [[[UIView alloc] initWithFrame:r] autorelease];
        UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:_searchBar 
                                                                                      action:@selector(resignFirstResponder)] autorelease];
        [_blindView addGestureRecognizer:recognizer];
        POOL_END;
    }
    return self;
}

- (void)dealloc {
    [_dateLabel release];
    [_searchBar release];
    [_blindView release];
    [_date release];
    [super dealloc];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    LOG_CURRENT_METHOD;
    [self.window addSubview:_blindView];
    
    SEL sel = @selector(searchBarShouldBeginEditing:);
    if ([_delegate respondsToSelector:sel]) {
        [_delegate performSelector:sel withObject:searchBar];
    }
    return YES;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    LOG_CURRENT_METHOD;
    SEL sel = @selector(searchBarTextDidBeginEditing:);
    if ([_delegate respondsToSelector:sel]) {
        [_delegate performSelector:sel withObject:searchBar];
    }
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    LOG_CURRENT_METHOD;
    [_blindView removeFromSuperview];
    
    SEL sel = @selector(searchBarShouldEndEditing:);
    if ([_delegate respondsToSelector:sel]) {
        [_delegate performSelector:sel withObject:searchBar];
    }
    return YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    LOG_CURRENT_METHOD;
    SEL sel = @selector(searchBarTextDidEndEditing:);
    if ([_delegate respondsToSelector:sel]) {
        [_delegate performSelector:sel withObject:searchBar];
    }
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    LOG_CURRENT_METHOD;
    SEL sel = @selector(searchBar:textDidChange:);
    if ([_delegate respondsToSelector:sel]) {
        NSMethodSignature *sig = [_delegate.class instanceMethodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:_delegate];
        [inv setArgument:&searchBar atIndex:2];
        [inv setArgument:&searchText atIndex:3];
        [inv setSelector:sel];
        [inv invoke];
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    LOG_CURRENT_METHOD;
    [_searchBar resignFirstResponder];
    
    SEL sel = @selector(searchBarSearchButtonClicked:);
    if ([_delegate respondsToSelector:sel]) {
        [_delegate performSelector:sel withObject:searchBar];
    }
}
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    LOG_CURRENT_METHOD;
    [_searchBar resignFirstResponder];
    SEL sel = @selector(searchBarBookmarkButtonClicked:);
    if ([_delegate respondsToSelector:sel]) {
        [_delegate performSelector:sel withObject:searchBar];
    }
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    LOG_CURRENT_METHOD;
    SEL sel = @selector(searchBarCancelButtonClicked:);
    if ([_delegate respondsToSelector:sel]) {
        [_delegate performSelector:sel withObject:searchBar];
    }
}
- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
    LOG_CURRENT_METHOD;
    SEL sel = @selector(searchBarResultsListButtonClicked:);
    if ([_delegate respondsToSelector:sel]) {
        [_delegate performSelector:sel withObject:searchBar];
    }
}
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    LOG_CURRENT_METHOD;
    SEL sel = @selector(searchBar:selectedScopeButtonIndexDidChange:);
    if ([_delegate respondsToSelector:sel]) {
        NSMethodSignature *sig = [_delegate.class instanceMethodSignatureForSelector:sel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:_delegate];
        [inv setArgument:&searchBar atIndex:2];
        [inv setArgument:&selectedScope atIndex:3];
        [inv setSelector:sel];
        [inv invoke];
    }
}

#pragma mark - Public

- (void)setDate:(NSDate *)date {
    LOG_CURRENT_METHOD;
    POOL_START;

    if (_date != date) {
        [_date release];
        _date = [date retain];

        NSDateFormatter *mdDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [mdDateFormatter setLocale:[NSLocale currentLocale]];
        [mdDateFormatter setDateFormat:@"MM/dd"];
        _dateLabel.text = [mdDateFormatter stringFromDate:_date];
    }
    
    POOL_END;
}


@end
