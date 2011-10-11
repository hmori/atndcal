//
//  ATRequestOperation.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+ATCategory.h"

extern NSString * const ATNotificationNameNoticeInfoRequest;

extern NSString * const ATNotificationNameCalendarEventsRequest;
extern NSString * const ATNotificationNameAttendeeUsersRequest;
extern NSString * const ATNotificationNameAttendeeTwitterUsersRequest;
extern NSString * const ATNotificationNameEventAttendRequest;
extern NSString * const ATNotificationNameEventCommentRequest;
extern NSString * const ATNotificationNameFbMeRequest;
extern NSString * const ATNotificationNameFbEventsRequest;
extern NSString * const ATNotificationNameFbEventDetailRequest;
extern NSString * const ATNotificationNameFbRsvpStatusRequest;
extern NSString * const ATNotificationNameFbUpdateRsvpStatusRequest;
extern NSString * const ATNotificationNameAnalysisRequest;
extern NSString * const ATNotificationNameProfileUserRequest;
extern NSString * const ATNotificationNameEventsRequest;

extern NSString * const kATRequestUserInfoStatusCode;
extern NSString * const kATRequestUserInfoReceivedData;
extern NSString * const kATRequestUserInfoError;

@interface ATRequestOperation : NSOperation {

	id _delegate;
    NSString *_notificationName;
	NSMutableDictionary *_userInfo;
	
	NSURLConnection *_connection;
    NSURLRequest *_request;
    NSURLResponse *_response;
	NSMutableData *_receivedData;
    
    BOOL _isExecuting;
    BOOL _isFinished;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, copy) NSString *notificationName;

@property BOOL isExecuting;
@property BOOL isFinished;

- (id)initWithDelegate:(id)delegate 
      notificationName:(NSString *)aName 
               request:(NSURLRequest *)request;
- (id)initWithDelegate:(id)delegate 
      notificationName:(NSString *)aName 
               request:(NSURLRequest *)request 
              userInfo:(NSMutableDictionary *)userInfo;

@end
