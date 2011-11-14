#import "ATActionSheet.h"

@interface ATActionSheet ()
@property (nonatomic, retain) NSMutableArray *buttonCallbacks;
@end

@implementation ATActionSheet
@synthesize cancelCallbackBlock = _cancelCallbackBlock;
@synthesize willPresentCallbackBlock = _willPresentCallbackBlock;
@synthesize didPresentCallbackBlock = _didPresentCallbackBlock;
@synthesize willDismissCallbackBlock = _willDismissCallbackBlock;
@synthesize didDismissCallbackBlock = _didDismissCallbackBlock;
@synthesize buttonCallbacks = _buttonCallbacks;

- (id)initWithTitle:(NSString *)title {
    self = [super initWithTitle:title delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        POOL_START;
        self.delegate = self;
        self.buttonCallbacks = [NSMutableArray array];
        POOL_END;
    }
    return self;
}

- (void)dealloc {
    [_cancelCallbackBlock release];
    [_willPresentCallbackBlock release];
    [_didPresentCallbackBlock release];
    [_willDismissCallbackBlock release];
    [_didDismissCallbackBlock release];
    [_buttonCallbacks release];
    [super dealloc];
}

- (void)addCancelButtonWithTitle:(NSString *)title callback:(ATActionSheetIndexBlock)callback {
    NSUInteger index = [self.buttonCallbacks count];
    [self addButtonWithTitle:title callback:callback];
    self.cancelButtonIndex = index;
}

- (void)addDestructiveButtonWithTitle:(NSString *)title callback:(ATActionSheetIndexBlock)callback {
    NSUInteger index = [self.buttonCallbacks count];
    [self addButtonWithTitle:title callback:callback];
    self.destructiveButtonIndex = index;
}

- (void)addButtonWithTitle:(NSString*)title callback:(ATActionSheetIndexBlock)callback {
    POOL_START;
    id obj = [NSNull null];
    if (callback) {
        obj = [[callback copy] autorelease];
    }
    [self addButtonWithTitle:title];
    [self.buttonCallbacks addObject:obj];
    POOL_END;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    id callback = [self.buttonCallbacks objectAtIndex:buttonIndex];
    if ((NSNull *)callback != [NSNull null]) {
        ((ATActionSheetIndexBlock)callback)((ATActionSheet *)actionSheet, buttonIndex);
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
    if (_cancelCallbackBlock) {
        _cancelCallbackBlock((ATActionSheet *)actionSheet);
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    if (_willPresentCallbackBlock) {
        _willPresentCallbackBlock((ATActionSheet *)actionSheet);
    }
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {
    if (_didPresentCallbackBlock) {
        _didPresentCallbackBlock((ATActionSheet *)actionSheet);
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (_willDismissCallbackBlock) {
        _willDismissCallbackBlock((ATActionSheet *)actionSheet, buttonIndex);
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (_didDismissCallbackBlock) {
        _didDismissCallbackBlock((ATActionSheet *)actionSheet, buttonIndex);
    }
}

@end