//
//  ATUser.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ATUser;

@interface ATUserManager : NSObject {
    
}
+ (ATUserManager *)sharedATUserManager;
+ (NSDictionary *)dictionaryWithJson:(NSString *)jsonString;
+ (ATUser *)userWithDictionary:(NSDictionary *)dictionary;
@end

@interface ATUser : NSObject {
    NSString *_user_id;
    NSString *_nickname;
    NSString *_twitter_id;
    NSString *_status;
}
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *twitter_id;
@property (nonatomic, copy) NSString *status;

@end
