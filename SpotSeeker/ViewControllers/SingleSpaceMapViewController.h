//
//  SingleSpotMapViewController.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "Spot.h"
#import "SingleSpaceMapAnnotation.h"

@interface SingleSpaceMapViewController : UIViewController <MKMapViewDelegate> {
    IBOutlet MKMapView *map_view;
    Spot *spot;
}

@property (nonatomic, retain) IBOutlet MKMapView *map_view;
@property (nonatomic, retain) Spot *spot;

@end
