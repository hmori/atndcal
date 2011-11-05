//
//  ATEvernoteConnecter.m
//  atndcal
//
//  Created by Mori Hidetoshi on 11/10/22.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ATEvernoteConnecter.h"
#import "ObjectSingleton.h"


NSString * const kDefaultsEvernoteUsername = @"kDefaultsEvernoteUsername";
NSString * const kDefaultsEvernotePassword = @"kDefaultsEvernotePassword";


@interface ATEvernoteConnecter ()
- (NSString *)errorMessage:(NSException *)exception;
@end


@implementation ATEvernoteConnecter
@synthesize authToken = _authToken;
@synthesize user = _user;
@synthesize noteStore = _noteStore;

NSString * const consumerKey  = kAtndcalEvernoteConsumerKey;
NSString * const consumerSecret = kAtndcalEvernoteConsumerSecret;

NSString * const userStoreUri = @"https://www.evernote.com/edam/user";
NSString * const noteStoreUriBase = @"https://www.evernote.com/edam/note/"; 

OBJECT_SINGLETON_TEMPLATE(ATEvernoteConnecter, sharedATEvernoteConnecter)

- (void)dealloc {
    [_authToken release];
    [_user release];
    [_noteStore release];
    [super dealloc];
}

#pragma mark - Public


- (BOOL)authorize {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    BOOL isSuccess = YES;

    NSURL *url = [[[NSURL alloc] initWithString: userStoreUri] autorelease];
    THTTPClient *userStoreHttpClient = [[[THTTPClient alloc] initWithURL:url] autorelease];
    TBinaryProtocol *userStoreProtocol = [[[TBinaryProtocol alloc] initWithTransport:userStoreHttpClient] autorelease];
    EDAMUserStoreClient *userStore = [[[EDAMUserStoreClient alloc] initWithProtocol:userStoreProtocol] autorelease];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults objectForKey:kDefaultsEvernoteUsername];
    NSString *password = [defaults objectForKey:kDefaultsEvernotePassword];
    
    EDAMAuthenticationResult *authResult = nil;
    
    @try {
        authResult = [userStore authenticate:username :password :consumerKey :consumerSecret];
        
        self.user = [authResult user];
        self.authToken = [authResult authenticationToken];
        NSString *shardId = [_user shardId];
        
        NSURL *noteStoreUri =  [[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", noteStoreUriBase, shardId] ] autorelease];
        
        THTTPClient *noteStoreHttpClient = [[[THTTPClient alloc] initWithURL:noteStoreUri userAgent:@"atndcal" timeout:15000] autorelease];
        TBinaryProtocol *noteStoreProtocol = [[[TBinaryProtocol alloc] initWithTransport:noteStoreHttpClient] autorelease];
        self.noteStore = [[[EDAMNoteStoreClient alloc] initWithProtocol:noteStoreProtocol] autorelease];
    }
    @catch (EDAMUserException *e) {
        NSString *message = [self errorMessage:e];
        [[TKAlertCenter defaultCenter] performSelectorOnMainThread:@selector(postAlertWithMessage:) 
                                                        withObject:message 
                                                     waitUntilDone:YES];
        isSuccess = NO;
    }
    POOL_END;

    return isSuccess;
}


- (BOOL)createNote:(NSDictionary *)param {
    LOG_CURRENT_METHOD;
    POOL_START;
    
    BOOL isSuccess = YES;

    NSString *title = [param objectForKey:@"title"];
    NSString *divContent = [param objectForKey:@"divContent"];
    NSString *tags = [param objectForKey:@"tags"];
    NSString *sourceURL = [param objectForKey:@"sourceURL"];
    
    
    static NSString *header = @""
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
    "<en-note>";
    
    static NSString *footer = @""
    "<br/>(<a href='http://itunes.apple.com/jp/app/id469446797?mt=8'>from ATND暦</a>)</en-note>";
    NSString *content = [NSString stringWithFormat:@"%@%@%@", header, divContent, footer];

    
    
    EDAMNote *note = [[[EDAMNote alloc] init] autorelease];
    [note setCreated:[[NSDate date] timeIntervalSince1970]*1000];

    if (title) {
        [note setTitle:title];
    }
    
    if (tags && [tags length] > 0) {
        NSArray *tagArray = [tags componentsSeparatedByString:@","];
        [note setTagNames:tagArray];
    }

    EDAMNoteAttributes *noteAttributes = [[[EDAMNoteAttributes alloc] init] autorelease];
    [noteAttributes setSource:@"mobile.atndcal"];
    [noteAttributes setSourceApplication:@"ATND暦"];
    if (sourceURL) {
        [noteAttributes setSourceURL:sourceURL];
    }
    [note setAttributes:noteAttributes];

    LOG(@"content=%@", content);
    [note setContent:content];

    if (!_authToken && !_noteStore) {
        isSuccess = [self authorize];
    }

    if (isSuccess) {
        @try {
            [_noteStore createNote:_authToken :note];
        }
        @catch (NSException *e) {
            LOG(@"EDAMUserException!!");
            NSString *message = [self errorMessage:e];
            [[TKAlertCenter defaultCenter] performSelectorOnMainThread:@selector(postAlertWithMessage:) 
                                                            withObject:message 
                                                         waitUntilDone:YES];
            isSuccess = NO;
        }
    }
    
    POOL_END;
    return isSuccess;
}

#pragma mark - Private

- (NSString *)errorMessage:(NSException *)exception {
	LOG_CURRENT_METHOD;
	
	int errorCode = 0;
	NSString *errorMessage = nil;
	if ([exception isKindOfClass:EDAMNotFoundException.class]) {
		errorMessage = @"サーバ上に見つかりません";
	} else if ([exception isKindOfClass:EDAMSystemException.class] || [exception isKindOfClass:EDAMUserException.class]) {
		if ([exception isKindOfClass:EDAMSystemException.class]) {
			errorCode = [(EDAMSystemException *)exception errorCode];
		} else {
			errorCode = [(EDAMUserException *)exception errorCode];
		}
		switch (errorCode) {
			case EDAMErrorCode_PERMISSION_DENIED:
                errorMessage = @"アクセスが許可されていません";
				break;
			case EDAMErrorCode_INTERNAL_ERROR:
                errorMessage = @"サーバに問題が発生しています";
				break;
			case EDAMErrorCode_LIMIT_REACHED:
                errorMessage = @"制限をオーバーしました";
				break;
			case EDAMErrorCode_QUOTA_REACHED:
                errorMessage = @"制限をオーバーしました";
				break;
			case EDAMErrorCode_INVALID_AUTH:
                errorMessage = @"パスワードが違います";
				break;
			case EDAMErrorCode_AUTH_EXPIRED:
                errorMessage = @"認証の期限が過ぎています";
				break;
			case EDAMErrorCode_DATA_CONFLICT:
                errorMessage = @"データが重複しています";
				break;
			case EDAMErrorCode_SHARD_UNAVAILABLE:
                errorMessage = @"サーバが一時的に停止しています";
				break;
			case EDAMErrorCode_UNKNOWN:
			case EDAMErrorCode_BAD_DATA_FORMAT:
			case EDAMErrorCode_DATA_REQUIRED:
			case EDAMErrorCode_ENML_VALIDATION:
			default:
                errorMessage = @"EvernoteAPIエラーが発生しました";
				break;
		}
	} else {
        errorMessage = @"EvernoteAPIエラーが発生しました";
	}
	
	return [NSString stringWithFormat:@"%@(%d)", errorMessage, errorCode];
}


@end
