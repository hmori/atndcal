#import "NSMutableURLRequest+ATCategory.h"


@implementation NSMutableURLRequest (ATCategory)

- (void)setPostData:(NSData *)postData {
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	[self setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[self setHTTPBody:postData];
}

@end
