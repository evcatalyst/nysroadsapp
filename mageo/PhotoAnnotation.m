//
//  PhotoAnnotation.m
//  mageo
//
//  Created by swallow on 2/1/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import "PhotoAnnotation.h"

@implementation PhotoAnnotation

@synthesize coordinate, title, subtitle, calloutCells, is_default, image, latitude, longitude;

- (void)copyAttributesFromAnnotation:(NSObject <PhotoAnnotationProtocol> *)annotation{
    coordinate = annotation.coordinate;
    title = [annotation.title copy];
    calloutCells = [annotation calloutCells];
    image = [annotation image];
    latitude = [annotation.latitude copy];
    longitude = [annotation.longitude copy];
}

@end
