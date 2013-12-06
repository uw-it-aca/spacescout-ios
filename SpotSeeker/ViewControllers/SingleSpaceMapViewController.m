//
//  SingleSpotMapViewController.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SingleSpaceMapViewController.h"


@implementation SingleSpaceMapViewController
@synthesize spot;
@synthesize map_view;

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation {
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
        
    NSString *annotationIdentifier = @"PinViewAnnotation";
    
    MKAnnotationView *pinView = (MKPinAnnotationView *) [map_view dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    
    if (!pinView) {
        pinView = [[MKAnnotationView alloc]
                   initWithAnnotation:annotation
                   reuseIdentifier:annotationIdentifier];        
    }
    else {
        pinView.annotation = annotation;
    }
        
    pinView.image = [UIImage imageNamed:@"pin00"];
    
    // XXX - This is the distance from the center of the image to the "point" of the pin drop. Needs to be updated with the images.
    pinView.centerOffset = CGPointMake(5, -20);
        
    return pinView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Single Space Map View";
    
    [map_view setShowsUserLocation:YES];

    
    MKCoordinateRegion mapRegion;   
    mapRegion.center =  CLLocationCoordinate2DMake([self.spot.latitude doubleValue], [self.spot.longitude doubleValue]);
    mapRegion.span.latitudeDelta = 0.001;
    mapRegion.span.longitudeDelta = 0.001;
    
    [map_view setRegion:mapRegion animated: NO];
    
    CLLocationCoordinate2D annotationCoord;
    annotationCoord.latitude = [self.spot.latitude floatValue];
    annotationCoord.longitude = [self.spot.longitude floatValue];
    
    SingleSpaceMapAnnotation *annotation = [[SingleSpaceMapAnnotation alloc] init];
    annotation.coordinate = annotationCoord;

    [self.map_view addAnnotation:annotation];

	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
