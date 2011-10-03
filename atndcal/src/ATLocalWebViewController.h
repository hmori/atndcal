//
//  ATLocalWebViewController.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ATLocalWebViewController : UIViewController {
  @private
    UIWebView *_webView;
    NSString *_filename;
    NSString *_titleString;
}

- (id)initWithFilename:(NSString *)filename title:(NSString *)title;

@end
