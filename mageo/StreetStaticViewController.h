//
//  StreetStaticViewController.h
//  mageo
//
//  Created by swallow on 2/21/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface StreetStaticViewController : UIViewController <MBProgressHUDDelegate>{
    
    BOOL be_img_loaded;
    
    MBProgressHUD * mbprogress_loading_img;
    NSMutableData * data_img_street;
    
    float width_img;
    float height_img;
}

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) double heading;

@property (weak, nonatomic) IBOutlet UIImageView *img_street;

@end
