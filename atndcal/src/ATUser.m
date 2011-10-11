//
//  ATUser.m
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ATUser.h"
#import "ObjectSingleton.h"
#import "NSString+SBJSON.h"

@implementation ATUserManager

OBJECT_SINGLETON_TEMPLATE(ATUserManager, sharedATUserManager)

static NSString * const kResults_returned = @"results_returned";
static NSString * const kResults_start = @"results_start";
static NSString * const kEvents = @"events";
static NSString * const kUsers = @"users";

static NSString * const kUser_id = @"user_id";
static NSString * const kNickname = @"nickname";
static NSString * const kTwitter_id = @"twitter_id";
static NSString * const kTwitter_img = @"twitter_img";
static NSString * const kStatus = @"status";


+ (NSDictionary *)dictionaryWithJson:(NSString *)jsonString {
    LOG_CURRENT_METHOD;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    
    id jsonData = [jsonString JSONValue];
	if ([jsonData isKindOfClass:NSDictionary.class]) {
        NSString *results_returned = [jsonData objectForKey:kResults_returned];
        NSString *results_start = [jsonData objectForKey:kResults_start];
        [dictionary setObject:results_returned forKey:kResults_returned];
        [dictionary setObject:results_start forKey:kResults_start];
        
        id events = [jsonData objectForKey:kEvents];
        if ([events isKindOfClass:NSArray.class]) {
            for (id e in events) {
/*
                NSString *event_id = [e objectForKey:@"event_id"];
                NSString *title = [e objectForKey:@"title"];
                LOG(@"-----");
                LOG(@"-event_id=%@", event_id);
                LOG(@"-title=%@", title);
*/
                id users = [e objectForKey:kUsers];
                [dictionary setObject:users forKey:kUsers];
            }
        }
    }
    return dictionary;
}

+ (ATUser *)userWithDictionary:(NSDictionary *)dictionary {
    ATUser *user = [[[ATUser alloc] init] autorelease];
    user.user_id = [dictionary objectForKey:kUser_id];
    user.nickname = [dictionary objectForKey:kNickname];
    user.twitter_id = [dictionary objectForKey:kTwitter_id];
    user.twitter_img = [dictionary objectForKey:kTwitter_img];
    user.status = [dictionary objectForKey:kStatus];
    return user;
}


@end



@implementation ATUser
@synthesize user_id = _user_id;
@synthesize nickname = _nickname;
@synthesize twitter_id = _twitter_id;
@synthesize twitter_img = _twitter_img;
@synthesize status = _status;

- (void)dealloc {
    [_user_id release];
    [_nickname release];
    [_twitter_id release];
    [_twitter_img release];
    [_status release];
    [super dealloc];
}

#pragma mark - Public


@end
