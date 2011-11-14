#import "ATTableData.h"


@implementation ATTableData

@synthesize rows=_rows;
@synthesize detailRows = _detailRows;
@synthesize images = _images;
@synthesize imageUrls = _imageUrls;
@synthesize accessorys = _accessorys;
@synthesize pushControllers=_pushControllers;
@synthesize title=_title;
@synthesize footer=_footer;

+ (ATTableData *)tableData {
    LOG_CURRENT_METHOD;
    return [[[ATTableData alloc] init] autorelease];
}

- (void)dealloc {
    [_rows release];
    [_detailRows release];
    [_images release];
    [_imageUrls release];
    [_accessorys release];
    [_pushControllers release];
    [_title release];
    [_footer release];
    [super dealloc];
}

@end
