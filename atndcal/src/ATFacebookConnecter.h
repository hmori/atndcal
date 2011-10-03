//
//  ATFacebookConnecter.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/09/17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FBConnect.h"

typedef enum {
    ATFacebookAuthStatusUnfinished,
    ATFacebookAuthStatusProcessing,
    ATFacebookAuthStatusSuccessed,
} ATFacebookAuthStatus;


typedef enum {
    ATFacebookRsvpStatusNoreply = -1,
    ATFacebookRsvpStatusAttending = 0,
    ATFacebookRsvpStatusMaybe = 1,
    ATFacebookRsvpStatusDeclined = 2,
    ATFacebookRsvpStatusInvited = -9,
} ATFacebookRsvpStatus;

@interface ATFacebookConnecter : NSObject <FBSessionDelegate, FBRequestDelegate> {
    Facebook *_facebook;
    
    ATFacebookAuthStatus _authStatus;
    
    NSData *_meData;
    NSUInteger _countUpdateMeData;
}
@property (nonatomic, readonly) Facebook *facebook;
@property (nonatomic, readonly) NSUInteger authStatus;
@property (nonatomic, readonly) NSUInteger countUpdateMeData;

- (NSDictionary *)dictionaryForMe;
- (NSArray *)facebookPermissions;
- (NSURLRequest *)requestWithObjectId:(NSString *)objectId;
- (NSURLRequest *)requestEventListForMe;
- (NSURLRequest *)requestSelectRsvpStatusOfEventId:(NSString *)eventId;
- (NSURLRequest *)requestUpdateRsvpStatus:(ATFacebookRsvpStatus)status eventId:(NSString *)eventId;

@end

@interface Facebook (Additions)
- (void)authorizeWithoutDialog:(NSArray *)permissions delegate:(id<FBSessionDelegate>)delegate;
@end

@interface FBRequest (Additions)
- (NSURLRequest *)getURLRequest;
@end