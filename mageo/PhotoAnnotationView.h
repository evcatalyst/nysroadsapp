//
//  PhotoAnnotationView.h
//  mageo
//
//  Created by swallow on 2/2/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import <MapKit/MapKit.h>

extern NSString* const MultiRowCalloutReuseIdentifier;


@protocol PhotoAnnotationProtocol;

@interface PhotoAnnotationView : MKAnnotationView

typedef void(^MultiRowAccessoryTappedBlock)();

+ (instancetype)calloutWithAnnotation:(id<PhotoAnnotationProtocol>)annotation onCalloutAccessoryTapped:(MultiRowAccessoryTappedBlock)block;

- (instancetype)initWithAnnotation:(id<PhotoAnnotationProtocol>)annotation reuseIdentifier:(NSString *)reuseIdentifier onCalloutAccessoryTapped:(MultiRowAccessoryTappedBlock)block NS_DESIGNATED_INITIALIZER;

@property (nonatomic,strong) NSArray *calloutCells;
@property (nonatomic,copy) MultiRowAccessoryTappedBlock onCalloutAccessoryTapped; // copied to cells
@property (nonatomic,unsafe_unretained) MKMapView *mapView;
@property (nonatomic,strong) MKAnnotationView *parentAnnotationView;

@end
