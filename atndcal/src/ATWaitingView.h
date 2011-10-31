//
//  ATWaitingView.h
//  atndcal
//
//  Created by Mori Hidetoshi on 11/10/21.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATWaitingView : UIView {
  @private
    TKLoadingView *_loadingView;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *message;


@end
