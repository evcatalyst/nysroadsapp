//
//  StreetViewController.m
//  mageo
//
//  Created by swallow on 2/14/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import "StreetViewController.h"

@interface StreetViewController (){
    GMSPanoramaView * panoView_;
}

@end

@implementation StreetViewController

@synthesize latitude, longitude, pano_view, heading;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[ pano_view moveNearCoordinate:CLLocationCoordinate2DMake(42.663913333333, 73.7694999999)];
    //[ pano_view moveNearCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
    
    //panoView_ = [[GMSPanoramaView alloc] initWithFrame:CGRectZero];
    //[panoView_ moveNearCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
    
    panoView_ = [[GMSPanoramaView alloc] initWithFrame:CGRectZero];
    self.view = panoView_;
    
    [panoView_ moveNearCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
    
    panoView_.camera = [GMSPanoramaCamera cameraWithHeading:heading
                                                      pitch:-10
                                                       zoom:1];
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
