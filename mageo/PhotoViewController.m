//
//  PhotoViewController.m
//  mageo
//
//  Created by swallow on 1/29/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import "PhotoViewController.h"
#import "PhotoDetailController.h"

#import "GmapAnnotationView.h"
#import "PhotoGMSMarker.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

@synthesize img_photo, mapview, mapview_container;

@synthesize btn_map;
@synthesize btn_pdf;
@synthesize btn_email;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    has_gps = [exif_data objectForKey:@"{GPS}"] != nil;
    is_map_initialized = false;

    if ( img_selected != nil ) {
        self.img_photo.image = img_selected;
    }
    
    
    
    [btn_map setTitle:@"Map" forState:UIControlStateNormal];
    [btn_map setEnabled:has_gps];
    
    if ( has_gps ) {
        
        // Create a location manager
        location_manager = [[CLLocationManager alloc] init];
        
        // Set a delegate to receive location callbacks
        location_manager.delegate = self;
        [ location_manager startUpdatingHeading];
        
        
        NSDictionary * gps_data = [exif_data objectForKey:@"{GPS}"];
        latitude = [ [gps_data objectForKey:@"Latitude"] doubleValue];
        longitude = [ [gps_data objectForKey:@"Longitude"] doubleValue];
        CLLocationCoordinate2D gps_pos = CLLocationCoordinate2DMake(latitude, longitude);
        
        /*panoView = [[GMSPanoramaView alloc] initWithFrame:CGRectZero];
        
        [mapview_container addSubview:panoView];
        panoView.frame = mapview.frame;
        
        [panoView moveNearCoordinate:CLLocationCoordinate2DMake(42.663913333333, 73.7694999999)];*/
        //[panoView moveNearCoordinate:gps_pos];

        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude
                                                                longitude:longitude
                                                                     zoom:15];
        
        gms_map_view = mapview;
        gms_map_view.camera = camera;
        [gms_map_view setDelegate:self ];
        
        gms_map_view.mapType =  kGMSTypeHybrid;
        gms_map_view.myLocationEnabled = YES;
        
        [mapview_container addSubview:gms_map_view];
        //gms_map_view.frame = mapview.frame;
        
        // Creates a marker in the center of the map.
        PhotoGMSMarker *marker = [[PhotoGMSMarker alloc] init];
        
        marker.position = gps_pos;
        
        //marker.title = @"Sydney";
        //marker.snippet = @"Australia";
        marker.map = gms_map_view;
        
        NSString * latitudeRef = (NSString *)[gps_data objectForKey:@"LatitudeRef"];
        NSString * longitudeRef = (NSString *)[gps_data objectForKey:@"LongitudeRef"];
        
        NSString * date = [gps_data objectForKey:@"DateStamp"];
        NSString * time = [gps_data objectForKey:@"TimeStamp"];
        
        NSString * date_time = date==nil? time: [date stringByAppendingString: [NSString stringWithFormat:@" %@", time ] ];
        NSString * str_latitude = [NSString stringWithFormat:@" %@ %f", latitudeRef, latitude ];
        NSString * str_longitude = [NSString stringWithFormat:@" %@ %f", longitudeRef, longitude ];
        
        marker.subject = date_time;
        marker.latitude = str_latitude;
        marker.longitude = str_longitude;
        
    }
    
    [ mapview setHidden:true ];
    [gms_map_view setHidden:true];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    // This is working, a new value is stored in "degrees" & logged on the console after each update. However it only seems to be updating "degrees" locally..
    int degrees = (int)location_manager.heading.magneticHeading;
    
    NSLog(@"from delegate method: %i", degrees);
    
    /*GMSCameraPosition *fancy = [gms_map_view camera];
    
    fancy = [GMSCameraPosition cameraWithLatitude:latitude
                                        longitude:longitude
                                             zoom:18
                                          bearing:degrees
                                     viewingAngle:90];
    
    //[gms_map_view setCamera:fancy];
    
    GMSCameraUpdate *bearingCamera = [GMSCameraUpdate setCamera:fancy];
    [gms_map_view animateWithCameraUpdate:bearingCamera];*/
}

#pragma mark - GMSMapViewDelegate

- (void) mapView: (GMSMapView *)mapView
didChangeCameraPosition: (GMSCameraPosition *)position
{
    latitude = mapView.camera.target.latitude;
    longitude = mapView.camera.target.longitude;
    // now do something with latitude and longitude
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) set_photo:(UIImage *)img{
    img_selected = img;
}

- (void) set_exif_data:(NSDictionary *)ed{
    exif_data = ed;
}

- (IBAction)on_click_btn_map:(id)sender {
    if ( [mapview isHidden] ) {
        [mapview setHidden:false];
        [gms_map_view setHidden:false];
        [btn_map setTitle:@"Photo" forState:UIControlStateNormal ];
        [self on_show_map];
    }else{
        [mapview setHidden:true];
        [gms_map_view setHidden:true];
        [btn_map setTitle:@"Map" forState:UIControlStateNormal ];
    }
}

- (IBAction)on_click_btn_pdf:(id)sender {
}

- (IBAction)on_click_btn_email:(id)sender {
}

- (void)on_show_map{
}

- (void)on_btn_exif{
    [self performSegueWithIdentifier:@"segue_photo_detail" sender:self];
}

// notification of finished loading a map
- (void)mapViewDidFinishLoadingMap:(MKMapView*)mapView {
    // show callout bubble without tapping
    [mapView selectAnnotation:[mapView.annotations lastObject] animated:YES];
    is_map_initialized = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segue_photo_detail"]) {
        [ [segue destinationViewController] setExif_data:exif_data];
    }
    
}

#pragma GMSMapViewDelegate

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker{
    
    PhotoGMSMarker * photo_marker = (PhotoGMSMarker *)marker;
    
    GmapAnnotationView * gmap_anno = [ [[NSBundle mainBundle] loadNibNamed:@"GmapAnnotationView" owner:self options:nil] objectAtIndex:0];
    
    [ gmap_anno.imgview_photo setImage:img_selected];
    [ gmap_anno.lbl_subject setText:photo_marker.subject ];
    [ gmap_anno.lbl_latitude setText:photo_marker.latitude ];
    [ gmap_anno.lbl_longitude setText:photo_marker.longitude ];
    [ gmap_anno setOnDisclosureTappedBlock:^() {
        // This is where I usually push in a new detail view onto the navigation controller stack, using the object's ID
        //NSLog(@"Representative (%@) with ID '%@' was tapped.", cell.subtitle, userData[@"id"]);
        [self on_btn_exif];
    }];
    
    [ gmap_anno initialize ];
    
    return  gmap_anno;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    // your code
}
@end
