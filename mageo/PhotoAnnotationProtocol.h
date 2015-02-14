//
//  PhotoAnnotationProtocol.h
//  mageo
//
//  Created by swallow on 2/2/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#ifndef mageo_PhotoAnnotationProtocol_h
#define mageo_PhotoAnnotationProtocol_h

#import <MapKit/MapKit.h>

@protocol PhotoAnnotationProtocol <NSObject,MKAnnotation>
@required
- (CLLocationCoordinate2D) coordinate;
- (NSString *)title;
- (NSString *)latitude;
- (NSString *)longitude;
- (NSArray *)calloutCells; // MultiRowCalloutCells
- (UIImage *)image;
@end

#endif
