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

#import "MBProgressHUD.h"

#import "NDHTMLtoPDF.h"

@class GMSMapView;
@class GMSPanoramaView;
@class GmapAnnotationView;
@class MBProgressHUD;

@interface PhotoViewController : UIViewController <CLLocationManagerDelegate,GMSMapViewDelegate, MBProgressHUDDelegate> {
    
    UIImage * img_selected;
    NSURL * url_selected;
    
    NSDictionary * exif_data;
    
    NSString * msg_printed;
    
    BOOL has_gps;
    BOOL is_map_initialized;
    
    GMSMapView *gms_map_view;
    GMSPanoramaView *panoView;
    
    CLLocationManager * location_manager;
    double latitude;
    double longitude;
    
    double latitude_photo;
    double longitude_photo;
    double heading_photo;
    
    //PhotoAnnotation * annotation_photo;
    //MKAnnotationView * annotation_view_selected;
    GmapAnnotationView * gmap_annotation_view;
    
    MBProgressHUD * mbprogress_road;
    MBProgressHUD * mbprogress_printing_pdf;
    
    NSMutableData * data_road;
    NSDictionary * dic_data_road;
    NSMutableDictionary * table_road_data;
    int fornextaction;
    
    BOOL be_loaded_dataroad;
    BOOL be_printed_pdf;
    
    NSString * filepath_pdf;
    
}

@property (weak, nonatomic) IBOutlet GMSMapView *mapview;
@property (weak, nonatomic) IBOutlet UIImageView *img_photo;
//@property (weak, nonatomic) IBOutlet UIView *mapview;
@property (weak, nonatomic) IBOutlet UIView *mapview_container;

@property (weak, nonatomic) IBOutlet UIButton *btn_map;
@property (weak, nonatomic) IBOutlet UIButton *btn_pdf;
@property (weak, nonatomic) IBOutlet UIButton *btn_email;
@property (weak, nonatomic) IBOutlet UIButton *btn_street;

@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;

- (void) set_photo:(UIImage *)img;
- (void) set_exif_data:(NSDictionary *)ed;
- (void) set_url_selected:(NSURL *)url;

- (IBAction)on_click_btn_map:(id)sender;
- (IBAction)on_click_btn_pdf:(id)sender;
- (IBAction)on_click_btn_email:(id)sender;
- (IBAction)on_click_btn_street:(id)sender;

@end
