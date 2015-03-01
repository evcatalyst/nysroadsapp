//
//  StreetViewController.h
//  mageo
//
//  Created by swallow on 2/14/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GoogleMaps/GoogleMaps.h>

@interface StreetViewController : UIViewController

@property (weak, nonatomic) IBOutlet GMSPanoramaView *pano_view;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) double heading;


@end
