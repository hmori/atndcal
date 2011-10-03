//
//  ATTableData.h
//  ATndCal
//
//  Created by Mori Hidetoshi on 11/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ATTableData : NSObject {
    NSMutableArray *_rows;
    NSMutableArray *_detailRows;
    NSMutableArray *_images;
    NSMutableArray *_imageUrls;
    NSMutableArray *_accessorys;
    NSMutableArray *_pushControllers;
    NSString *_title;
    NSString *_footer;
}
@property (nonatomic, retain) NSMutableArray *rows;
@property (nonatomic, retain) NSMutableArray *detailRows;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableArray *imageUrls;
@property (nonatomic, retain) NSMutableArray *accessorys;
@property (nonatomic, retain) NSMutableArray *pushControllers;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *footer;

+ (ATTableData *)tableData;

@end
