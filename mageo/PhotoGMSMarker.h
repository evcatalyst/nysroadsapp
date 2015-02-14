//
//  PhotoGMSMarker.h
//  mageo
//
//  Created by swallow on 2/10/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>

@interface PhotoGMSMarker : GMSMarker

@property (readwrite, nonatomic, copy) NSString* subject;

@property (readwrite, nonatomic, copy) NSString* latitude;
@property (readwrite, nonatomic, copy) NSString* longitude;

@property (nonatomic,unsafe_unretained) UIImage * image;


@end
