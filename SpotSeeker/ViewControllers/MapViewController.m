//
//  MapViewController.m
//  SpotSeeker
//
//  Copyright 2012 UW Information Technology, University of Washington
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MapViewController.h"

@implementation MapViewController

@synthesize spot;
@synthesize map_view;
@synthesize current_spots;



-(IBAction)btnClickSearch:(id)sender { 
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setValue:[NSArray arrayWithObjects:@"1", nil] forKey:@"open_now"];
    [attributes setValue:[NSArray arrayWithObjects:@"1", nil] forKey:@"extended_info:ada_accessible"];
    [attributes setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", map_view.centerCoordinate.latitude], nil] forKey:@"center_latitude"];
    [attributes setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", map_view.centerCoordinate.longitude], nil] forKey:@"center_longitude"];

    int meters = map_view.region.span.latitudeDelta * meters_per_latitude;
    [attributes setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%i", meters], nil] forKey:@"distance"];

    Spot *_spot = [Spot alloc];
    self.spot = _spot;
    [self.spot getListBySearch:attributes];
    [self.spot setDelegate:self];
}

-(IBAction)btnClickFilter:(id)sender {
    MapFilterViewController *filter_controller = [[MapFilterViewController alloc] init];
    [self presentModalViewController:filter_controller animated:TRUE];
}

-(void) searchFinished:(NSArray *)spots {
    self.current_spots = spots;
    [self showFoundSpots:spots];
}

-(void) showFoundSpots:(NSArray *)spots {
    [self removeAnnotations];
    
    int index;
    for (index = 0; index < spots.count; index++) {
        spot = [spots objectAtIndex:index];

        CLLocationCoordinate2D annotationCoord;
        annotationCoord.latitude = [spot.latitude floatValue];
        annotationCoord.longitude = [spot.longitude floatValue];
        
        SpotAnnotation *annotationPoint = [[SpotAnnotation alloc] init];
        annotationPoint.coordinate = annotationCoord;
        annotationPoint.title = [spot name];
        annotationPoint.spot_index = [NSNumber numberWithInt:index];
        [map_view addAnnotation:annotationPoint]; 
    }
   
}

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation {
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if (![annotation isKindOfClass:[SpotAnnotation class]])
        return nil;
    
    NSString *annotationIdentifier = @"PinViewAnnotation";
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView *) [map_view dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
  
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc]
                   initWithAnnotation:annotation
                   reuseIdentifier:annotationIdentifier];
        
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [button addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag: [((SpotAnnotation *)annotation).spot_index intValue]];
        pinView.rightCalloutAccessoryView = button;
    }
    else
    {
        pinView.annotation = annotation;
    }
  
    return pinView;    
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation 
{
    MKCoordinateRegion mapRegion;   
    mapRegion.center = map_view.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.005;
    mapRegion.span.longitudeDelta = 0.005;
    
    [map_view setRegion:mapRegion animated: YES];
}

- (void)showDetails:(id)sender {
    [self performSegueWithIdentifier:@"show_details" sender: sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SpotDetailsViewControllerViewController *details = segue.destinationViewController;

    [details setSpot:[self.current_spots objectAtIndex:[sender tag]]];
}


-(void) removeAnnotations {
    int index;
    for (index = map_view.annotations.count - 1; index >= 0; index --) {
        NSObject <MKAnnotation> *test = [map_view.annotations objectAtIndex:index];
        if ([test isKindOfClass:[SpotAnnotation class]]) {
            [map_view removeAnnotation:test];
        }
    }

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
    map_view.delegate = self;
    [map_view setShowsUserLocation:YES];

//    NSLog(map_view.userLocation);
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

@end
