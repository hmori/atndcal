//
//  ATEventTextCell.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATEventTextCell : TKLabelFieldCell {
    BOOL _truncate;
}
@property (getter = isTruncate) BOOL truncate;
+ (CGFloat)heightCellOfLabelText:(NSString *)text truncate:(BOOL)truncate;

@end
