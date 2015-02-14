//
//  PhotoViewController.h
//  mageo
//
//  Created by swallow on 1/29/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PhotoAnnotation.h"
#import <GoogleMaps/GoogleMaps.h>

@class GMSMapView;
@class GMSPanoramaView;

@interface PhotoViewController : UIViewController <CLLocationManagerDelegate,GMSMapViewDelegate> {
    
    UIImage * img_selected;
    
    NSDictionary * exif_data;
    
    BOOL has_gps;
    BOOL is_map_initialized;
    
    GMSMapView *gms_map_view;
    GMSPanoramaView *panoView;
    
    CLLocationManager * location_manager;
    double latitude;
    double longitude;
    
    //PhotoAnnotation * annotation_photo;
    //MKAnnotationView * annotation_view_selected;
}

@property (weak, nonatomic) IBOutlet GMSMapView *mapview;
@property (weak, nonatomic) IBOutlet UIImageView *img_photo;
//@property (weak, nonatomic) IBOutlet UIView *mapview;
@property (weak, nonatomic) IBOutlet UIView *mapview_container;

@property (weak, nonatomic) IBOutlet UIButton *btn_map;
@property (weak, nonatomic) IBOutlet UIButton *btn_pdf;
@property (weak, nonatomic) IBOutlet UIButton *btn_email;

- (void) set_photo:(UIImage *)img;
- (void) set_exif_data:(NSDictionary *)ed;

- (IBAction)on_click_btn_map:(id)sender;
- (IBAction)on_click_btn_pdf:(id)sender;
- (IBAction)on_click_btn_email:(id)sender;

@end
