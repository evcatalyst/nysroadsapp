//
//  PhotoSelectViewController.h
//  mageo
//
//  Created by swallow on 1/29/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotoViewController.h"

@class EXFMetaData;

@interface PhotoSelectViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate >
{
    UIActionSheet *actionsheet_photo;
    UIImagePickerController * img_picker;
    UIImage * img_selected;
    
    NSDictionary * exif_data;
    //EXFMetaData * exif_data;
    
    CLLocationManager * location_manager;
}

@property (weak, nonatomic) IBOutlet UIButton *btn_select_photo;

- (IBAction)on_click_btn_select_photo:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *img_preview;

@end
