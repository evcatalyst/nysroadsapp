//
//  PhotoDetailController.m
//  mageo
//
//  Created by swallow on 2/3/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import "PhotoDetailController.h"
#import "NSDictionary+MetadataDatasource.h"

@implementation PhotoDetailController

@synthesize exif_data;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ( exif_data == nil) {
        return;
    }
    
    detail_data = [ [NSMutableDictionary alloc] initWithDictionary:exif_data copyItems:true];
    
    //[detail_data objectForKey:@"{MakerApple}"] = @"";
    
    if ( [detail_data objectForKey:@"{MakerApple}"]) {
        [detail_data removeObjectForKey:@"{MakerApple}"];
        [detail_data setValue:@"" forKey:@"{MakerApple}"];
    }
    
    self.tableview_photo.delegate = detail_data;
    self.tableview_photo.dataSource = detail_data;
    self.tableview_photo.rowHeight = 25;
    
}



@end
