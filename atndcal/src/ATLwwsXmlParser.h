#import <Foundation/Foundation.h>
#import "ATLwws.h"

@interface ATLwwsXmlParser : NSObject <NSXMLParserDelegate> {
  @private
    ATLwws *_lwws;
    NSMutableString *_buffer;
    
    BOOL _isPinpoint;
    BOOL _isCopyright;
    BOOL _isImage;
    BOOL _isMax;
    BOOL _isMin;
}
@property (nonatomic, retain) ATLwws *lwws;

- (void)parse:(NSData *)data;

@end
