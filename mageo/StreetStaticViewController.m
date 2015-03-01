//
//  StreetStaticViewController.m
//  mageo
//
//  Created by swallow on 2/21/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import "StreetStaticViewController.h"
#import "curl.h"
#import "MBProgressHUD.h"

#define STREETAPI_URL @"https://maps.googleapis.com/maps/api/streetview?size=%dx%d&location=%f,%f&fov=90&heading=%f&pitch=10"

extern size_t writefunc(void *ptr, size_t size, size_t nmemb, NSMutableData * s );

@interface StreetStaticViewController ()

@end

@implementation StreetStaticViewController

@synthesize latitude, longitude, heading, img_street;

- (void)loading_img_street{
    
    be_img_loaded = false;
    BOOL be_success_curl = false;
    
    data_img_street = [[NSMutableData alloc] init];
    
    // Do something usefull in here instead of sleeping ...
    CURL *curl;
    CURLcode res;
    
    curl = curl_easy_init();
    if(curl) {
        
        //latitude_photo = -73.750324f;
        //longitude_photo = 42.646445f;
        
        NSString * url = [ NSString stringWithFormat:STREETAPI_URL, (int)width_img, (int)height_img, latitude, longitude, heading ];
        
        curl_easy_setopt( curl, CURLOPT_URL, [url cStringUsingEncoding:NSUTF8StringEncoding] );
        /* example.com is redirected, so we tell libcurl to follow redirection */
        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
        
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writefunc);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, data_img_street );
        
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
    
    be_img_loaded = true;
}

- (void)hudWasHidden:(MBProgressHUD *)hud{
    
    if ( hud == mbprogress_loading_img ) {
        if (be_img_loaded ) {
            [self showImage];
            //NSLog( @"%f, %f", img_street.frame.size.width, img_street.frame.size.height );
        }else{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                            message:NSLocalizedString(@"Does not get street view image Error", @"")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    
}

- (void)showImage{
    UIImage *img = [ [UIImage alloc] initWithData:data_img_street];
    img_street.image = img;
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    width_img = img_street.frame.size.width;
    height_img = img_street.frame.size.height;
    
    if ( be_img_loaded) {
        [self showImage];
        return;
    }
    
    
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    mbprogress_loading_img = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:mbprogress_loading_img];
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    mbprogress_loading_img.delegate = self;
    
    // Show the HUD while the provided method executes in a new thread
    [mbprogress_loading_img showWhileExecuting:@selector(loading_img_street) onTarget:self withObject:nil animated:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    be_img_loaded = false;
    
    
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

@end
