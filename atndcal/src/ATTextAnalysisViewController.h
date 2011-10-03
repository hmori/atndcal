//
//  ATTextAnalysisViewController.h
//  atndcal
//
//  Created by Mori Hidetoshi on 11/09/29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
