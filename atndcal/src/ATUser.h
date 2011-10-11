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
    id _user_id;
    id _nickname;
    id _twitter_id;
    id _twitter_img;
    id _status;
}
@property (nonatomic, copy) id user_id;
@property (nonatomic, copy) id nickname;
@property (nonatomic, copy) id twitter_id;
@property (nonatomic, copy) id twitter_img;
@property (nonatomic, copy) id status;

@end
