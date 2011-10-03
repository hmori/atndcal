//
//  ATCalendarTitleView.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ATCalendarTitleViewDelegate;

@interface ATCalendarTitleView : UIView <UISearchBarDelegate> {
    id<ATCalendarTitleViewDelegate> _delegate;
    UILabel *_dateLabel;
    UISearchBar *_searchBar;
    UIView *_blindView;
    NSDate *_date;
}
@property (nonatomic, assign) id<ATCalendarTitleViewDelegate> delegate;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UIView *blindView;
@property (nonatomic, retain) NSDate *date;

- (void)setDate:(NSDate *)date;

@end


@protocol ATCalendarTitleViewDelegate <NSObject>

@optional
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar;
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar;
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar;
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;
- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_2);
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);

@end
