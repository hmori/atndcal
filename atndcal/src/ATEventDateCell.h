//
//  ATEventDateTableViewCell.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TapkuLibrary/TapkuLibrary.h>

@interface ATEventDateCell : TKLabelFieldCell {
    UILabel *_startField;
    UILabel *_endField;
}
@property (nonatomic, retain) UILabel *startField;
@property (nonatomic, retain) UILabel *endField;

@end
