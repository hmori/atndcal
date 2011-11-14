#import <UIKit/UIKit.h>
#import "ATTableViewController.h"

@interface ATTextAnalysisViewController : ATTableViewController {
  @private
    NSString *_sentence;

    NSMutableArray *_keyphraseArray;
    NSMutableArray *_accessoryArray;
}
@property (nonatomic, copy) NSString *sentence;

- (void)reloadAction:(id)sender;
- (void)closeAction:(id)sender;
- (void)openWebView:(id)sender url:(NSString *)urlString;

@end
