#import <UIKit/UIKit.h>
#import "ATTableViewController.h"

@protocol ATWordSelectDelegate;

@interface ATWordSelectViewCotroller : ATTableViewController {
    id<ATWordSelectDelegate> _delegate;
}
@property (nonatomic, assign) id<ATWordSelectDelegate> delegate;

- (void)closeAction:(id)sender;

@end

@protocol ATWordSelectDelegate <NSObject>
- (void)wordSelect:(NSString *)text;
@end
