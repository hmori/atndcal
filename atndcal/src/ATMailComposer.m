#import "ATMailComposer.h"

@interface ATMailComposer ()
- (void)openMail;
- (void)displayComposerSheet;
- (void)launchMailAppOnDevice;
@end


@implementation ATMailComposer
@synthesize toRecipients = _toRecipients;
@synthesize ccRecipients = _ccRecipients;
@synthesize bccRecipients = _bccRecipients;
@synthesize subject = _subject;
@synthesize body = _body;
@synthesize isHTML = _isHTML;

- (void)dealloc {
    [_toRecipients release];
    [_ccRecipients release];
    [_bccRecipients release];
    [_subject release];
    [_body release];
    
    _controller = nil;
    [super dealloc];
}

#pragma mark - setter

- (void)setToRecipient:(NSString *)toRecipient {
    [_toRecipients release];
    _toRecipients = [[NSArray alloc] initWithObjects:toRecipient, nil];
}

- (void)setCcRecipient:(NSString *)ccRecipient {
    [_ccRecipients release];
    _ccRecipients = [[NSArray alloc] initWithObjects:ccRecipient, nil];
}

- (void)setBccRecipient:(NSString *)bccRecipient {
    [_bccRecipients release];
    _bccRecipients = [[NSArray alloc] initWithObjects:bccRecipient, nil];
}

#pragma mark - Public

- (void)openMailOnViewController:(UIViewController *)controller {
    _controller = controller;
    [self openMail];
}

#pragma mark - Private

- (void)openMail {
	LOG_CURRENT_METHOD;
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil && [mailClass canSendMail]) {
		[self displayComposerSheet];
	} else {
		[self launchMailAppOnDevice];
	}
}

- (void)displayComposerSheet {
    POOL_START;

	MFMailComposeViewController *picker = [[[MFMailComposeViewController alloc] init] autorelease];
    
	picker.mailComposeDelegate = self;
    if (_toRecipients) {
        [picker setToRecipients:_toRecipients];
    }
    if (_ccRecipients) {
        [picker setCcRecipients:_ccRecipients];
    }
    if (_bccRecipients) {
        [picker setBccRecipients:_bccRecipients];
    }
    if (_subject) {
        [picker setSubject:_subject];
    }
    if (_body) {
        [picker setMessageBody:_body isHTML:_isHTML];
    }
	[_controller presentModalViewController:picker animated:YES];

    POOL_END;
}

- (void)launchMailAppOnDevice {
    static NSString *emailFormat = @"mailto:%@?cc=%@&bcc=%@&subject=%@&body=%@";
    NSString *mailString = 
    [[NSString stringWithFormat:emailFormat, 
      ((_toRecipients && _toRecipients.count > 0)?[_toRecipients componentsJoinedByString:@","]:@""), 
      ((_ccRecipients && _ccRecipients.count > 0)?[_ccRecipients componentsJoinedByString:@","]:@""), 
      ((_bccRecipients && _bccRecipients.count > 0)?[_bccRecipients componentsJoinedByString:@","]:@""), 
      _subject?_subject:@"", 
      _body?_body:@""] 
     stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURL *mailUrl = [NSURL URLWithString:mailString];
    UIApplication *app = [UIApplication sharedApplication];
    if ([app canOpenURL:mailUrl]) {
        [app openURL:mailUrl];
    } else {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"メールが利用できません."];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {	
	NSString *message = nil;
	switch (result) {
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
            message = @"メールの下書きに登録されました.";
			break;
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed:
            message = @"送信に失敗しました.\nメールの下書きに登録します.";
			break;
		default:
            message = @"送信に失敗しました.";
			break;
	}
	
	if (message) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:message];
	}
	[_controller dismissModalViewControllerAnimated:YES];
}

@end
