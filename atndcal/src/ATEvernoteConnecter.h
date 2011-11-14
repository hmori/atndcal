#import <Foundation/Foundation.h>

#import "THTTPClient.h"
#import "TBinaryProtocol.h"
#import "UserStore.h"
#import "NoteStore.h"
#import "Errors.h"


extern NSString * const kDefaultsEvernoteUsername;
extern NSString * const kDefaultsEvernotePassword;



@interface ATEvernoteConnecter : NSObject {
  @private
    NSString *_authToken;
    EDAMUser *_user;
    EDAMNoteStoreClient *_noteStore;
    
}
+ (ATEvernoteConnecter *)sharedATEvernoteConnecter;

@property (nonatomic, retain) NSString *authToken; 
@property (nonatomic, retain) EDAMUser *user;
@property (nonatomic, retain) EDAMNoteStoreClient *noteStore;

- (BOOL)authorize;
- (BOOL)createNote:(NSDictionary *)param;
//- (BOOL)connect;

@end
