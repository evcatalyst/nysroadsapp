//
//  PhotoSelectViewController.m
//  mageo
//
//  Created by swallow on 1/29/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//


#import "PhotoSelectViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "NSMutableDictionary+ImageMetadata.h"

//#import "EXF.h"

#import <ImageIO/ImageIO.h>

BOOL gLogging;



@interface PhotoSelectViewController ()

@end

@implementation PhotoSelectViewController

@synthesize btn_select_photo;
@synthesize img_preview;



- (void)viewDidLoad {
    
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    img_picker = [[UIImagePickerController alloc] init];
    img_picker.delegate = self;
    
    // Create a location manager
    location_manager = [[CLLocationManager alloc] init];
    
    // Set a delegate to receive location callbacks
    location_manager.delegate = self;
    
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

- (IBAction)on_click_btn_select_photo:(id)sender {
    
    actionsheet_photo = [[UIActionSheet alloc] initWithTitle:@"Select Photo"
                                                    delegate:self
                                           cancelButtonTitle:nil
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:@"From Gallery", @"Take Photo with camera",nil];
    
    
    actionsheet_photo.cancelButtonIndex = [actionsheet_photo addButtonWithTitle:@"Cancel"];
    [actionsheet_photo setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [actionsheet_photo showInView:[[UIApplication sharedApplication] keyWindow]];
    
}

# pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == actionsheet_photo)
    {
        switch (buttonIndex) {
            case 0:
                [self on_click_btn_from_gallery];
                break;
            case 1:
                [self on_click_btn_from_camera];
                break;
            default:
                break;
        }
    }
}



- (void)on_click_btn_from_gallery{

    img_picker.delegate = self;
    img_picker.allowsEditing = YES;
    img_picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:img_picker animated:YES completion:nil];
}



- (void)on_click_btn_from_camera{
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    //if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
    if ( status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        
        alertView.tag = 10;
        
        [alertView show];
        
        //return;
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        
        if ([location_manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [location_manager requestWhenInUseAuthorization];
        }
        
        [location_manager startUpdatingLocation];
        
        //return;
    }
    
    [self on_handle_camera ];
    
}

- (void) on_handle_camera{
    
    @try
    {
        //        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //        imagePicker.delegate = self;
        //
        //        [self presentViewController:imagePicker animated:YES completion:nil];
        img_picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        img_picker.delegate = self;
        img_picker.allowsEditing = YES;
        
        [self presentViewController:img_picker animated:YES completion:nil];
    }
    
    @catch (NSException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera" message:@"Camera is not available" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( alertView.tag ==10 && buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}


// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", [locations lastObject]);
}

# pragma mark Image Picker Delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//#define TEMPIMAGE_FILENAME           @"MyPhoto.jpg"
//#define TEMPIMAGERECOMPRESS_FILENAME @"MyPhotoRecomp.jpg"


- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    exif_data = nil;
    
    img_selected = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
    //NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    //NSString *saveJpgFile;
    //NSString *saveJpgFileRecompress;
    //saveJpgFile = [ NSTemporaryDirectory() stringByAppendingPathComponent: TEMPIMAGE_FILENAME ];
    //saveJpgFileRecompress = [ NSTemporaryDirectory() stringByAppendingPathComponent:TEMPIMAGERECOMPRESS_FILENAME];
    
    //HandlePhoto * handlePhoto = [ [HandlePhoto alloc] init ];
    
    //BOOL sts = [ handlePhoto saveTemporaryJpegFiles:[assetURL absoluteString] fileName:saveJpgFile fileNameRecompress:saveJpgFileRecompress];
    
    BOOL sts = true;
    //sts = [UIImageJPEGRepresentation(img_selected, 1.0) writeToFile:saveJpgFile atomically:true];
    
    //location_manager.location.altitude;
    
    NSString * msg = nil;
    if (!sts) {
        msg = NSLocalizedString(@"TempJpegFileError", @"");
    }else{
        
        //ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        
        NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        
        if ( assetURL != nil ) {
            [ self on_handle_with_asseturl:assetURL picker:picker ];
            return;
        }
        
        //NSDictionary * metaData = [info objectForKey:UIImagePickerControllerMediaMetadata];
        
        NSMutableDictionary *metaData = [[NSMutableDictionary alloc] initWithDictionary:[info objectForKey:UIImagePickerControllerMediaMetadata]];
        
        [ metaData setLocation:location_manager.location ];
        [ metaData setDateDigitized:[NSDate date]];
        [ metaData setDateOriginal:[NSDate date] ];
        
        exif_data = metaData;
        
        [self performSegueWithIdentifier:@"segue_photoview" sender:self];
        
        
        /*[library writeImageToSavedPhotosAlbum:img_selected.CGImage metadata:metaData completionBlock:
         ^(NSURL *assetURL, NSError *error) {
             [self on_handle_with_asseturl:assetURL picker:picker];
         } ];*/
        
        //[library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        //NSURL * asset_private_url = [NSURL URLWithString:[saveJpgFile stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
    //}
    /*UIGraphicsBeginImageContext(img.size);
     [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
     img = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();*/
    
    
    /*NSData * uiJpeg = UIImageJPEGRepresentation (img_selected, 1.0 );
     
     
     EXFJpeg *jpegScanner = [[EXFJpeg alloc] init];
     
     [jpegScanner scanImageData: uiJpeg ];
     exif_data = [jpegScanner exifMetaData];
     //id longitude = [exif_data tagValue:[NSNumber numberWithInt:EXIF_GPSLongitude]];
     //id longitudeRef = [exif_data tagValue:[NSNumber numberWithInt:EXIF_GPSLongitudeRef]];
     //id longitude = [exif_data tagValue:[NSNumber numberWithInt:EXIF_ColorSpace]];
     //id longitudeRef = [exif_data tagValue:[NSNumber numberWithInt:EXIF_Compression]];
     //id value = [ exif_data tagValue: [NSNumber numberWithInt:EXIF_GPSAltitudeRef] ];
     //NSLog(@"Longitude: %@ %@", longitudeRef, longitude);
     //[jpegScanner release];*/
    
}


- (void) on_handle_with_asseturl:(NSURL*)assetURL picker:(UIImagePickerController *)picker {
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        if (representation == nil ) {
        }else{
            exif_data = [representation metadata];
            NSLog(@"%@", exif_data);
        }
        
        //self.textView.text = [metadataDict description];
        if ( exif_data == nil ) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"File Error"
                                                            message:NSLocalizedString(@"Cannot extract Exif Data", @"")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles:nil];
            [alert show];
        }else{
            [self performSegueWithIdentifier:@"segue_photoview" sender:self];
        }
        
        
    } failureBlock:^(NSError *error) {
        NSLog(@"%@",error);
        if ( exif_data == nil ) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"File Error"
                                                            message:NSLocalizedString(@"Cannot extract Exif Data", @"")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segue_photoview"]) {
        [ [segue destinationViewController] set_photo:img_selected];
        [ [segue destinationViewController] set_exif_data:exif_data];
    }
    
}



@end

