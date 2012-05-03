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
@synthesize search_attributes;

int const meters_per_latitude = 111 * 1000;

-(void) runSearch {
    if (search_attributes == nil) {
        search_attributes = [[NSMutableDictionary alloc] init];
    }
    [search_attributes setValue:[NSArray arrayWithObjects:@"1", nil] forKey:@"open_now"];
    [search_attributes setValue:[NSArray arrayWithObjects:@"1", nil] forKey:@"extended_info:ada_accessible"];
    [search_attributes setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", map_view.centerCoordinate.latitude], nil] forKey:@"center_latitude"];
    [search_attributes setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", map_view.centerCoordinate.longitude], nil] forKey:@"center_longitude"];
    
    int meters = map_view.region.span.latitudeDelta * meters_per_latitude;
    [search_attributes setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%i", meters], nil] forKey:@"distance"];
    
    Spot *_spot = [Spot alloc];
    self.spot = _spot;
    [self.spot getListBySearch:search_attributes];
    [self.spot setDelegate:self];

}

-(void) runSearchWithAttributes:(NSMutableDictionary *)attributes {
    self.search_attributes = attributes;
    [self runSearch];
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

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self runSearch];
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
    if ([[segue identifier] isEqualToString:@"search_filter"]) {
        MapFilterViewController *filter_vc = segue.destinationViewController;
        filter_vc.user_latitude = [[NSNumber alloc] initWithDouble: self.map_view.centerCoordinate.latitude];
        filter_vc.user_longitude = [[NSNumber alloc] initWithDouble: self.map_view.centerCoordinate.longitude];
        filter_vc.user_distance = [[NSNumber alloc] initWithDouble: map_view.region.span.latitudeDelta * meters_per_latitude ];
    }
    else if ([[segue identifier] isEqualToString:@"show_details"]) {
        SpotDetailsViewController *details = segue.destinationViewController;

        [details setSpot:[self.current_spots objectAtIndex:[sender tag]]];
    }
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
