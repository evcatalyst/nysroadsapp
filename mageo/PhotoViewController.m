//
//  PhotoViewController.m
//  mageo
//
//  Created by swallow on 1/29/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import "PhotoViewController.h"
#import "PhotoDetailController.h"
#import "RoadDetailViewController.h"
#import "PDFViewController.h"

#import "GmapAnnotationView.h"
#import "PhotoGMSMarker.h"

#import "curl.h"

#import "NSDictionary+MetadataDatasource.h"

#import "Mail.h"

#import <math.h>

#import "StreetViewController.h"
#import "StreetStaticViewController.h"

#define URLGetNearByRoads "http://getnearbyroads.azurewebsites.net/api/gis/GetNearByRoads"

#define ACTION_DETAIL_ROAD 0
#define ACTION_EMAIL_SEND 1
#define ACTION_PRINT_PDF 2

@interface PhotoViewController ()

@end

@implementation PhotoViewController

@synthesize img_photo, mapview, mapview_container, PDFCreator;

@synthesize btn_map;
@synthesize btn_pdf;
@synthesize btn_email, btn_street;

size_t writefunc(void *ptr, size_t size, size_t nmemb, NSMutableData * s )
{
    [s appendBytes:ptr length:size*nmemb];
    
    return size*nmemb;
}

- (void)loading_road_task:(NSNumber *)for_nextaction{
    
    int nextaction = [for_nextaction intValue];

    be_loaded_dataroad = false;
    BOOL be_success_curl = false;
    
    data_road = [[NSMutableData alloc] init];
    
    // Do something usefull in here instead of sleeping ...
    CURL *curl;
    CURLcode res;
    
    curl = curl_easy_init();
    if(curl) {
        
        //latitude_photo = -73.750324f;
        //longitude_photo = 42.646445f;
        
        //NSString * url = [NSString stringWithFormat:@"%s?latitude=%f&longitude=%f", URLGetNearByRoads, latitude_photo, longitude_photo ];
        NSString * url = [NSString stringWithFormat:@"%s?latitude=%f&longitude=%f", URLGetNearByRoads, longitude_photo, latitude_photo ];
        
        curl_easy_setopt( curl, CURLOPT_URL, [url cStringUsingEncoding:NSUTF8StringEncoding] );
        /* example.com is redirected, so we tell libcurl to follow redirection */
        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
        
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writefunc);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, data_road );
        
        /* Perform the request, res will get the return code */
        res = curl_easy_perform(curl);
        /* Check for errors */
        if(res != CURLE_OK){
            fprintf(stderr, "curl_easy_perform() failed: %s\n",
                    curl_easy_strerror(res));
        }else{
            be_success_curl = true;
        }
        /* always cleanup */
        curl_easy_cleanup(curl);
    }
    
    if ( !be_success_curl ) {
        return;
    }
    
    id id_data = [NSJSONSerialization JSONObjectWithData:data_road options:NSJSONReadingMutableLeaves error:nil];
    
    if ( ![id_data isKindOfClass:[NSArray class]] ) {
        return;
    }
    
    NSArray * data = id_data;
    
    if ( data.count < 1 ) {
        return;
    }
    
    NSDictionary * dic_data = data[0];
    
    NSString * FID = [dic_data objectForKey:@"FID"];
    
    if ( FID == nil ) {
        return;
    }
    
    dic_data_road = dic_data;
    
    NSMutableDictionary * road_info = [ [NSMutableDictionary alloc] initWithDictionary:dic_data_road copyItems:true];
    
    [ road_info exchangeKey:@"Name" withKey:@"Name of the Road" inMutableDictionary:road_info ];
    [ road_info exchangeKey:@"Type" withKey:@"Type of the Road" inMutableDictionary:road_info ];
    [ road_info exchangeKey:@"FID" withKey:@"Road ID" inMutableDictionary:road_info ];
    [ road_info exchangeKey:@"SHIELD" withKey:@"shield info" inMutableDictionary:road_info ];
    [ road_info exchangeKey:@"HighwayNum" withKey:@"highway number" inMutableDictionary:road_info ];
    [ road_info exchangeKey:@"JURISDICTI" withKey:@"MOST IMPORTANT PIECE OF DATA" inMutableDictionary:road_info ];
    [ road_info exchangeKey:@"Shape_Leng" withKey:@"Road Segment Length" inMutableDictionary:road_info ];
    
    NSString * str_left_country = [road_info objectForKey:@"LeftCounty" ];
    NSString * str_right_country = [ road_info objectForKey:@"RightCount" ];
    NSString * str_country = [ NSString stringWithFormat:@"%@ - %@", str_left_country, str_right_country ];
    [ road_info setObject:str_country forKey:@"<LeftCounty> - <Right County>" ];
    [ road_info removeObjectForKey: @"LeftCounty" ];
    [ road_info removeObjectForKey: @"RightCount" ];
    
    NSString * str_left_city = [road_info objectForKey:@"LeftCityTo" ];
    NSString * str_right_city = [ road_info objectForKey:@"RightCityT" ];
    NSString * str_city = [ NSString stringWithFormat:@"%@ - %@", str_left_city, str_right_city ];
    [ road_info setObject:str_city forKey:@"<LeftCityTo> - <RightCityT>" ];
    [ road_info removeObjectForKey: @"LeftCityTo" ];
    [ road_info removeObjectForKey: @"RightCityT" ];
    
    table_road_data = [ [NSMutableDictionary alloc] init ];
    
    [ table_road_data setObject:road_info forKey:@"Road Info" ];
    
    be_loaded_dataroad = true;
    self->fornextaction = nextaction;
}

- (void)printing_pdf_task:(NSNumber *)for_nextaction{
    
    int nextaction = [for_nextaction intValue];
    
    
    /*[ NDHTMLtoPDF createPDFWithHTML:html_content baseURL:baseURL pathForPDF:pdfFilePath pageSize:kPaperSizeA4 margins:UIEdgeInsetsMake(10, 5, 10, 5) successBlock:^(NDHTMLtoPDF *htmlToPDF) {
        NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
        NSLog(@"%@",result);
        //self.resultLabel.text = result;
    } errorBlock:^(NDHTMLtoPDF *htmlToPDF) {
        NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
        NSLog(@"%@",result);
        //self.resultLabel.text = result;
    }];*/
    
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[NSURL URLWithString:@"http://edition.cnn.com/2013/09/19/opinion/rushkoff-apple-ios-baby-steps/index.html"] pathForPDF:[@"~/Documents/blocksDemo.pdf" stringByExpandingTildeInPath] pageSize:kPaperSizeA4 margins:UIEdgeInsetsMake(10, 5, 10, 5) successBlock:^(NDHTMLtoPDF *htmlToPDF) {
        NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
        NSLog(@"%@",result);
        //self.resultLabel.text = result;
        filepath_pdf = htmlToPDF.PDFpath;
        [self show_print];
    } errorBlock:^(NDHTMLtoPDF *htmlToPDF) {
        NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
        NSLog(@"%@",result);
        //self.resultLabel.text = result;
    }];
    
    //[PDFRenderer createPDF:pdfFilePath image:img_selected message:message ];
    
    be_printed_pdf = true;
    //filepath_pdf = pdfFilePath;
    self->fornextaction = nextaction;
}

- (void)hudWasHidden:(MBProgressHUD *)hud{
    
    if ( hud == mbprogress_road ) {
        
        if (!be_loaded_dataroad) {
            data_road = nil;
            dic_data_road = nil;
            table_road_data = nil;
            [self on_failed_loading_dataroad];
            return;
        }
        
        if (self->fornextaction == ACTION_DETAIL_ROAD) {
            [ self on_click_btn_road ];
        }else if (self->fornextaction == ACTION_EMAIL_SEND){
            [ self send_email ];
        }else if( self->fornextaction == ACTION_PRINT_PDF ){
            [ self do_print ];
        }
        
    }else if ( hud == mbprogress_printing_pdf ){
        if( self->fornextaction == ACTION_PRINT_PDF ){
            if ( be_printed_pdf ) {
                [self show_print];
            }
        }
    }
    
}

- (void) on_failed_loading_dataroad{

    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Server Error"
                                                    message:NSLocalizedString(@"Server Error", @"")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                          otherButtonTitles:nil];
    [alert show];

}

- (void) on_click_btn_road{
    [self performSegueWithIdentifier:@"segue_detail_road" sender:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    be_loaded_dataroad = false;
    msg_printed = nil;
    has_gps = [exif_data objectForKey:@"{GPS}"] != nil;
    is_map_initialized = false;
    filepath_pdf = nil;

    if ( img_selected != nil ) {
        self.img_photo.image = img_selected;
    }
    
    
    
    [btn_map setTitle:@"Map" forState:UIControlStateNormal];
    [btn_map setEnabled:has_gps];
    [btn_pdf setEnabled:has_gps];
    [btn_email setEnabled:has_gps];
    [btn_street setEnabled:has_gps];
    
    if ( has_gps ) {
        
        // Create a location manager
        location_manager = [[CLLocationManager alloc] init];
        
        // Set a delegate to receive location callbacks
        location_manager.delegate = self;
        [ location_manager startUpdatingHeading];
        
        NSDictionary * gps_data = [exif_data objectForKey:@"{GPS}"];
        latitude_photo = latitude = [ [gps_data objectForKey:@"Latitude"] doubleValue ];
        longitude_photo = longitude = [ [gps_data objectForKey:@"Longitude"] doubleValue ];
        
        NSString * latitude_ref = [gps_data objectForKey:@"LatitudeRef"];
        NSString * longitude_ref = [gps_data objectForKey:@"LongitudeRef"];
        
        if ( [latitude_ref  isEqual:@"S"] ) {
            latitude_photo = latitude = ( -1 * latitude );
        }
        
        if ( [longitude_ref  isEqual:@"W"] ) {
            longitude_photo = longitude = ( -1 * longitude );
        }
        
        heading_photo = [ [ gps_data objectForKey:@"ImgDirection" ] doubleValue ];
        NSString * heading_ref = [ gps_data objectForKey:@"ImgDirectionRef" ] ;
        if ( ![heading_ref isEqual:@"T" ]) {
            heading_photo = (-1* heading_photo);
        }
        
        CLLocationCoordinate2D gps_pos = CLLocationCoordinate2DMake(latitude, longitude);
        
        /*panoView = [[GMSPanoramaView alloc] initWithFrame:CGRectZero];
        
        [mapview_container addSubview:panoView];
        panoView.frame = mapview.frame;
        
        //[panoView moveNearCoordinate:CLLocationCoordinate2DMake(42.663913333333, 73.7694999999)];
        [panoView moveNearCoordinate:gps_pos];*/

        
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
        NSString * str_latitude = [NSString stringWithFormat:@" %@ %f", latitudeRef, fabs(latitude) ];
        NSString * str_longitude = [NSString stringWithFormat:@" %@ %f", longitudeRef, fabs(longitude) ];
        
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
    
    if (mapView.selectedMarker != nil && gmap_annotation_view.superview) {
        [self replaceCalloutViewForCoordinates:[mapView.selectedMarker position] inMap:mapView];
    } else {
        [gmap_annotation_view removeFromSuperview];
    }

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
    
    NSDictionary * gps_data = [ed objectForKey:@"{GPS}"];
    
    double imgDirection = [ [gps_data objectForKey:@"ImgDirection"] doubleValue ];
    
    NSString * imgDirectionRef = [gps_data objectForKey:@"ImgDirectionRef"];
    
    if ( [imgDirectionRef isEqualToString:@"T"] ) {
        if ( imgDirection < 180.0f ) {
            imgDirection += 180.0f;
        }else{
            imgDirection -= 180.0f;
        }
    }
    
    [ gps_data setValue:[NSNumber numberWithDouble:imgDirection] forKey:@"ImgDirection" ];
    
    exif_data = ed;
}

- (void) set_url_selected:(NSURL *)url{
    url_selected = url;
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
    
    if (!be_loaded_dataroad ) {
        [ self loading_road_data:ACTION_PRINT_PDF ];
        return;
    }
    
    [self do_print];
    
}

- (IBAction)on_click_btn_email:(id)sender {
    
    if ( !be_loaded_dataroad ) {
        [self loading_road_data:ACTION_EMAIL_SEND];
        return;
    }
    
    [self send_email];
}

- (IBAction)on_click_btn_street:(id)sender {
    //[ self performSegueWithIdentifier:@"segue_show_street" sender:self ];
    [ self performSegueWithIdentifier:@"segue_show_street_static" sender:self ];
}

- (void)on_show_map{
}

- (void)on_btn_exif{
    [self performSegueWithIdentifier:@"segue_photo_detail" sender:self];
}

- (void)on_btn_road{
    
    if ( dic_data_road != nil ) {
        [ self on_click_btn_road ];
        return;
    }
    
    [self loading_road_data:ACTION_DETAIL_ROAD];
}

- (void)loading_road_data:(int)for_nextaction{
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    mbprogress_road = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:mbprogress_road];
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    mbprogress_road.delegate = self;
    
    // Show the HUD while the provided method executes in a new thread
    [mbprogress_road showWhileExecuting:@selector(loading_road_task:) onTarget:self withObject:[NSNumber numberWithInt:for_nextaction] animated:YES];
}

- (void)printing_pdf_data:(int)for_nextaction{
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    mbprogress_printing_pdf = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:mbprogress_printing_pdf];
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    mbprogress_printing_pdf.delegate = self;
    
    // Show the HUD while the provided method executes in a new thread
    [mbprogress_printing_pdf showWhileExecuting:@selector(printing_pdf_task:) onTarget:self withObject:[NSNumber numberWithInt:for_nextaction] animated:YES];
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
    }else if( [[segue identifier] isEqualToString:@"segue_detail_road" ] ){
        [ [segue destinationViewController] setTable_road_data:table_road_data];
    }else if ([[segue identifier] isEqualToString:@"segue_show_pdf" ] ){
        [ [segue destinationViewController] setFilepath_pdf:filepath_pdf];
    }else if( [[segue identifier] isEqualToString:@"segue_show_street"] ){
        StreetViewController * st_view = [segue destinationViewController];
        [ st_view setLatitude:latitude_photo];
        [ st_view setLongitude:longitude_photo];
        [ st_view setHeading:heading_photo];
    }else if( [[segue identifier] isEqualToString:@"segue_show_street_static"] ){
        StreetStaticViewController * st_view = [segue destinationViewController];
        [ st_view setLatitude:latitude_photo];
        [ st_view setLongitude:longitude_photo];
        [ st_view setHeading:heading_photo];
    }
    
}

- (void)replaceCalloutViewForCoordinates:(CLLocationCoordinate2D)coordinate inMap:(GMSMapView *)pMapView {
    CLLocationCoordinate2D anchor = [pMapView.selectedMarker position];
    
    CGPoint arrowPt = CGPointMake(CGRectGetWidth(gmap_annotation_view.frame) / 2.0, CGRectGetHeight(gmap_annotation_view.frame));
    
    CGPoint pt = [pMapView.projection pointForCoordinate:anchor];
    
    pt.x -= arrowPt.x;
    
    float marker_height = 36.0f;
    if ([pMapView.selectedMarker icon] ) {
        marker_height = [pMapView.selectedMarker icon].size.height;
    }
    pt.y -= arrowPt.y +  marker_height/*height of POI Image*/;
    
    gmap_annotation_view.frame = (CGRect) {.origin = pt, .size = gmap_annotation_view.frame.size };
}

#pragma GMSMapViewDelegate

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker{
    
    PhotoGMSMarker * photo_marker = (PhotoGMSMarker *)marker;
    
    //if ([[marker userData][kShouldDisplayCallout] boolValue]) {
    GmapAnnotationView * gmap_anno = [ [[NSBundle mainBundle] loadNibNamed:@"GmapAnnotationView" owner:self options:nil] objectAtIndex:0];
    gmap_annotation_view = gmap_anno;
    
    [ gmap_anno.imgview_photo setImage:img_selected];
    [ gmap_anno.lbl_subject setText:photo_marker.subject ];
    [ gmap_anno.lbl_latitude setText:photo_marker.latitude ];
    [ gmap_anno.lbl_longitude setText:photo_marker.longitude ];
    [ gmap_anno setOnDisclosureTappedBlock:^() {
        // This is where I usually push in a new detail view onto the navigation controller stack, using the object's ID
        //NSLog(@"Representative (%@) with ID '%@' was tapped.", cell.subtitle, userData[@"id"]);
        [self on_btn_exif];
    }];
    
    [ gmap_anno setOnRoadTappedBlock:^(){
        [ self on_btn_road ];
    }];
    
    [gms_map_view addSubview:gmap_anno];
    [ self replaceCalloutViewForCoordinates:marker.position inMap:mapView];
    
    return [[UIView alloc] initWithFrame:gmap_anno.frame];
    
    //}
    
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [gmap_annotation_view removeFromSuperview];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    // your code
}

#pragma SENDING EMAIL

- (void)send_email{

    Mail *mail = [[Mail alloc] init];
    
    NSString * message_exif,  *message_road, *message;
    
    message_exif = [ self get_message_from_dictionary:exif_data general_key:@"{General}" ];
    message_road = [ self get_message_from_dictionary:table_road_data general_key:@"{ROAD}" ];
    
    message = [ NSString stringWithFormat:@"%@\n%@", message_exif, message_road ];
    
    NSString *jpgName = @"PHOTO";
    NSArray *attachFiles = [NSArray arrayWithObjects:url_selected, nil];
    NSArray *attachFileNames = [NSArray arrayWithObjects:jpgName, nil];
    NSArray *attachFileTypes = [NSArray arrayWithObjects:@"image/jpeg", nil];
    
    [mail createMail:self
            delegate:self
             useHtml:NO
             subject:jpgName
             message:message
                  to:nil
                  cc:nil
                 bcc:nil
         attachFiles:attachFiles
     attachFileNames:attachFileNames
     attachFileTypes:attachFileTypes
deleteAttachFileSource:NO];
    
}

// mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    switch (result){
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            //[Uty msgBox:NSLocalizedString(@"SendError", @"") title:APP_NAME];
            break;
    }
    // finish mailer UI
    [self dismissViewControllerAnimated:YES completion: ^{
        //[self doneModal:YES];
    }];
}

- (void) do_print{
    
    /*if ( !be_printed_pdf ) {
        [ self printing_pdf_data:ACTION_PRINT_PDF ];
        return;
    }
    
    [self show_print ];*/
    
    
    NSString * html_content = [ self get_message_printed_html ];
    
    NSURL *baseURL = [NSURL URLWithString:NSTemporaryDirectory()] ;
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@.pdf", (__bridge NSString *)uuidString];
    //NSString *uniqueFileName = [NSString stringWithFormat:@"%@.html", (__bridge NSString *)uuidString];
    
    
    //NSString * pdfFilePath = [ NSTemporaryDirectory() stringByAppendingPathComponent: @"MyPhoto.pdf" ];
    NSString * pdfFilePath = [ NSTemporaryDirectory() stringByAppendingPathComponent: uniqueFileName ];

    /*[ html_content writeToFile:pdfFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    filepath_pdf = pdfFilePath;
    be_printed_pdf = true;*/

    if (be_printed_pdf) {
        [ self show_print ];
        return;
    }


    if ( mbprogress_printing_pdf == nil ) {
        // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
        mbprogress_printing_pdf = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:mbprogress_printing_pdf];
        
        // Regiser for HUD callbacks so we can remove it from the window at the right time
        //mbprogress_printing_pdf.delegate = self;
    }
    
    
    
    [ mbprogress_printing_pdf show:true ];
    
    self.PDFCreator = [ NDHTMLtoPDF createPDFWithHTML:html_content baseURL:baseURL pathForPDF:pdfFilePath pageSize:kPaperSizeA4 margins:UIEdgeInsetsMake(50, 5, 50, 5) successBlock:^(NDHTMLtoPDF *htmlToPDF) {
        
        [ mbprogress_printing_pdf hide:true ];
        
        be_printed_pdf = true;
        
        NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
        filepath_pdf = htmlToPDF.PDFpath;
        [self show_print];
        NSLog(@"%@",result);
        //self.resultLabel.text = result;
    } errorBlock:^(NDHTMLtoPDF *htmlToPDF) {
        
        be_printed_pdf = false;
        
        [ mbprogress_printing_pdf hide:true ];
        
        NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
        NSLog(@"%@",result);
        //self.resultLabel.text = result;
    }];
    
    /*self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[NSURL URLWithString:@"http://edition.cnn.com/2013/09/19/opinion/rushkoff-apple-ios-baby-steps/index.html"] pathForPDF:[@"~/Documents/blocksDemo.pdf" stringByExpandingTildeInPath] pageSize:kPaperSizeA4 margins:UIEdgeInsetsMake(10, 5, 10, 5) successBlock:^(NDHTMLtoPDF *htmlToPDF) {
        NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
        filepath_pdf = htmlToPDF.PDFpath;
        [self show_print];
        NSLog(@"%@",result);
        //self.resultLabel.text = result;
    } errorBlock:^(NDHTMLtoPDF *htmlToPDF) {
        NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
        NSLog(@"%@",result);
        //self.resultLabel.text = result;
    }];*/
}

- (void) show_print{
    [self performSegueWithIdentifier:@"segue_show_pdf" sender:self];
}

- (NSString *)get_message_printed{
    
    if ( msg_printed != nil ) {
        return msg_printed;
    }
    
    NSString * message_exif = [ self get_message_from_dictionary:exif_data general_key:@"{General}" ];
    NSString * message_road = [ self get_message_from_dictionary:table_road_data general_key:@"{ROAD}" ];
    
    msg_printed = [ NSString stringWithFormat:@"%@\n%@", message_exif, message_road ];
    
    return msg_printed;
}

- (NSString *)get_message_printed_html{
    
    NSString * msg = [ [NSString alloc] init ];
    
    // begin HTML
    msg = [msg stringByAppendingString:[NSString stringWithFormat:@"<html><head></head><body style='text-align:center' >"] ];
    
    // insert image
    msg = [msg stringByAppendingString:[NSString stringWithFormat:@"<div style='text-align:center;margin: 40px 0;' ><img src='%@?pizaa=%f' style='max-width:300px' /></div>", url_selected, [[NSDate date] timeIntervalSince1970] ] ];
    
    msg = [msg stringByAppendingString:[NSString stringWithFormat:@"<div style='text-align:left;margin:0 auto;width: 500px;word-wrap:normal;word-break: break-word;' ><pre>%@</pre></div>", [ self get_message_printed ] ] ];
    
    // end HTML
    msg = [msg stringByAppendingString:[NSString stringWithFormat:@"</body></html>"] ];
    
    return msg;
}

- (NSString *)get_message_from_dictionary:(NSDictionary *)dic_data
                              general_key:(NSString *)general_key
{

    NSString * msg = [ [NSString alloc] init ];
    
    id key;
    id value;
    
    NSMutableDictionary * general = [ [NSMutableDictionary alloc] init ];
    
    for ( key in dic_data.allKeys ){
        value = [dic_data objectForKey:key];
        if ( [ value isKindOfClass:[NSDictionary class] ]) {
            continue;
        }
        [general setObject:value forKey:key ];
    }
    
    if ( [ general count] > 0) {
        msg = [msg stringByAppendingString:[NSString stringWithFormat:@"%@\n", general_key ] ];
        for ( key in general.allKeys ){
            msg = [msg stringByAppendingString:[NSString stringWithFormat:@"- %@: %@\n", key, [general objectForKey:key] ] ];
        }
    }
    
    id sub_key;
    id sub_value;
    
    for ( key in dic_data.allKeys ) {
        
        value = [dic_data objectForKey:key];
        if ( ![value isKindOfClass:[NSDictionary class] ] ) {
            continue;
        }
        
        NSString * str_key = key;
        
        if ( [str_key isEqual: @"{MakerApple}"] ) {
            continue;
        }
        
        msg = [ msg stringByAppendingString:[NSString stringWithFormat:@"%@\n", key ] ];
        
        NSDictionary * dic_value = (NSDictionary *)value;
        
        for ( sub_key in dic_value.allKeys ) {
            sub_value = [ dic_value objectForKey:sub_key ];
            if ( [ sub_value isKindOfClass:[NSArray class] ] ) {
                msg = [ msg stringByAppendingString:[NSString stringWithFormat:@"- %@: %@\n", sub_key, [sub_value componentsJoinedByString:@","]] ];
            }else{
                msg = [ msg stringByAppendingString:[NSString stringWithFormat:@"- %@: %@\n", sub_key, sub_value ] ];
            }
        }
    }
    
    return msg;
}

@end
