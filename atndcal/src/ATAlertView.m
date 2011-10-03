//
//  ATAlertView.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATAlertView.h"

@interface ATAlertView ()
@property (nonatomic, retain) NSMutableArray *buttonCallbacks;
- (BOOL)hasCancelButton;
@end

@implementation ATAlertView

@synthesize willPresentCallbackBlock = _willPresentCallbackBlock;
@synthesize didPresentCallbackBlock = _didPresentCallbackBlock;
@synthesize willDismissCallbackBlock = _willDismissCallbackBlock;
@synthesize didDismissCallbackBlock = _didDismissCallbackBlock;
@synthesize buttonCallbacks = _buttonCallbacks;

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle {
    self = [super initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    if (self) {
        POOL_START;
        self.delegate = self;
        self.buttonCallbacks = [NSMutableArray array];
        if ([self hasCancelButton]) {
            [self setCancelButtonCallback:^(ATAlertView *alertView, NSInteger index){}];
        }
        POOL_END;
    }
    return self;
}

- (void)dealloc {
    [_willPresentCallbackBlock release];
    [_didPresentCallbackBlock release];
    [_willDismissCallbackBlock release];
    [_didDismissCallbackBlock release];
    [_buttonCallbacks release];
    
    [super dealloc];
}

- (void)addButtonWithTitle:(NSString *)title callback:(ATAlertViewIndexBlock)callback {
    POOL_START;
    id obj = [NSNull null];
    if (callback) {
        obj = [[callback copy] autorelease];
    }
    [self addButtonWithTitle:title];
    [self.buttonCallbacks addObject:obj];
    POOL_END;
}

- (void)setCancelButtonCallback:(ATAlertViewIndexBlock)callback {
    POOL_START;
    if ([self hasCancelButton]) {
        if ([self.buttonCallbacks count] > 0) {
            [self.buttonCallbacks removeObjectAtIndex:0];
        }
        [self.buttonCallbacks insertObject:[[callback copy] autorelease] atIndex:0];
    }
    POOL_END;
}

- (BOOL)hasCancelButton {
    return (self.cancelButtonIndex == 0);
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    id callback = [self.buttonCallbacks objectAtIndex:buttonIndex];
    if ((NSNull *)callback != [NSNull null]) {
        ((ATAlertViewIndexBlock)callback)((ATAlertView *)alertView, buttonIndex);
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    if(_willPresentCallbackBlock) {
        _willPresentCallbackBlock((ATAlertView *)alertView);
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
    if(_didPresentCallbackBlock) {
        _didPresentCallbackBlock((ATAlertView *)alertView);
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(_willDismissCallbackBlock) {
        _willDismissCallbackBlock((ATAlertView *)alertView, buttonIndex);
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(_didDismissCallbackBlock) {
        _didDismissCallbackBlock((ATAlertView *)alertView, buttonIndex);
    }
}

@end