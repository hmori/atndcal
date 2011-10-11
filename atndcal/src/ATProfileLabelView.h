//
//  ATProfileLabelView.h
//  atndcal
//
//  Created by Mori Hidetoshi on 11/10/04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ATProfileLabelView : UIView {
    UIImageView *_imageView;
    UIActivityIndicatorView *_indicatorView;

    UILabel *_label;
    NSString *_imageUrl;
}
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, copy) NSString *imageUrl;

- (void)stopIndicator;

@end
