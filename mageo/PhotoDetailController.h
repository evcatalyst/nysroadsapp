//
//  PhotoDetailController.h
//  mageo
//
//  Created by swallow on 2/3/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoDetailController : UIViewController{
    NSMutableDictionary * detail_data;
}

@property (weak, nonatomic) IBOutlet UITableView *tableview_photo;

@property (nonatomic,strong) NSDictionary * exif_data;

@end
