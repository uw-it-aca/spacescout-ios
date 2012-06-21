//
//  SingleSpotMapViewController.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SingleSpotMapViewController.h"


@implementation SingleSpotMapViewController
@synthesize spot;
@synthesize map_view;

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
    self.title = self.spot.name;
    
    MKCoordinateRegion mapRegion;   
    mapRegion.center =  CLLocationCoordinate2DMake([self.spot.latitude doubleValue], [self.spot.longitude doubleValue]);
    mapRegion.span.latitudeDelta = 0.001;
    mapRegion.span.longitudeDelta = 0.001;
    
    [map_view setRegion:mapRegion animated: NO];
    
    CLLocationCoordinate2D annotationCoord;
    annotationCoord.latitude = [self.spot.latitude floatValue];
    annotationCoord.longitude = [self.spot.longitude floatValue];
    
    SingleSpotMapAnnotation *annotation = [[SingleSpotMapAnnotation alloc] init];
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

@end
