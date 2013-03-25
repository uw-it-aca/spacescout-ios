//
//  SingleSpotMapViewController.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "Space.h"
#import "SingleSpaceMapAnnotation.h"
#import "GAITrackedViewController.h"

@interface SingleSpaceMapViewController : GAITrackedViewController <MKMapViewDelegate> {
    IBOutlet MKMapView *map_view;
    Space *spot;
}

@property (nonatomic, retain) IBOutlet MKMapView *map_view;
@property (nonatomic, retain) Space *spot;

@end
