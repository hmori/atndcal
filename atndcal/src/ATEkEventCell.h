//
//  ATEkEventCell.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TapkuLibrary/TapkuLibrary.h>
#import <eventkit/EventKit.h>
#import <eventkitui/EventKitUI.h>

@interface ATEkEventCell : TKIndicatorCell {
    EKEvent *_ekEvent;
}
@property (nonatomic, retain) EKEvent *ekEvent;

@end
