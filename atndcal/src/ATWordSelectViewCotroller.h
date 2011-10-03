//
//  ATWordSelectViewCotroller.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
