//
//  PhotoAnnotation.h
//  mageo
//
//  Created by swallow on 2/1/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import "PhotoAnnotationProtocol.h"

@interface PhotoAnnotation : NSObject<PhotoAnnotationProtocol>

@property (readwrite, nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (readwrite, nonatomic, copy) NSString* title;
@property (readwrite, nonatomic, copy) NSString* subtitle;

@property (readwrite, nonatomic, copy) NSString* latitude;
@property (readwrite, nonatomic, copy) NSString* longitude;

@property (nonatomic,unsafe_unretained) UIImage * image;
@property (readwrite, nonatomic) BOOL is_default;
@property (nonatomic,copy) NSArray *calloutCells; // MultiRowCalloutCells

- (void)copyAttributesFromAnnotation:(NSObject <PhotoAnnotationProtocol> *)annotation;

@end
