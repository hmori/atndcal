//
//  ATMailComposer.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <TapkuLibrary/TapkuLibrary.h>

@interface ATMailComposer : NSObject <MFMailComposeViewControllerDelegate> {
    NSArray *_toRecipients;
    NSArray *_ccRecipients;
    NSArray *_bccRecipients;
    NSString *_subject;
    NSString *_body;
    BOOL _isHTML;

  @private
    UIViewController *_controller;
}
@property (nonatomic, retain) NSArray *toRecipients;
@property (nonatomic, retain) NSArray *ccRecipients;
@property (nonatomic, retain) NSArray *bccRecipients;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *body;
@property (nonatomic) BOOL isHTML;

- (void)setToRecipient:(NSString *)toRecipient;
- (void)setCcRecipient:(NSString *)ccRecipient;
- (void)setBccRecipient:(NSString *)bccRecipient;

- (void)openMailOnViewController:(UIViewController *)controller;

@end
