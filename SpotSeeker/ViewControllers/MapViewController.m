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

@synthesize current_clusters;
@synthesize from_list;
@synthesize map_region;
@synthesize cluster_spots_to_display;

extern const int meters_per_latitude;

-(void) showFoundSpots {
    [self removeAnnotations];

    NSArray *annotation_groups = [AnnotationCluster createClustersFromSpots:self.current_spots andMap:map_view];
    
    for (int index = 0; index < annotation_groups.count; index++) {
        AnnotationCluster *cluster = [annotation_groups objectAtIndex:index];
        CLLocationCoordinate2D annotationCoord;
        annotationCoord.latitude = [cluster.display_latitude floatValue];
        annotationCoord.longitude = [cluster.display_longitude floatValue];

        Spot *first_in_group = [cluster.spots objectAtIndex:0];
        SpotAnnotation *annotationPoint = [[SpotAnnotation alloc] init];
        annotationPoint.coordinate = annotationCoord;
        annotationPoint.spots = cluster.spots;
        annotationPoint.title = [first_in_group name];
        annotationPoint.cluster_index = [NSNumber numberWithInt:index];
        [map_view addAnnotation:annotationPoint]; 
    }
    self.current_clusters = annotation_groups;
}

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation {
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if (![annotation isKindOfClass:[SpotAnnotation class]])
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

    SpotAnnotation *actual = (SpotAnnotation *)annotation;
    
    int spot_count = actual.spots.count;
    if (spot_count > 33) {
        spot_count = 33;
    }

    if (spot_count > 1) {
        pinView.canShowCallout = false;
    }
    else {
        pinView.canShowCallout = true;
    }
    
    NSString *image_name = [NSString stringWithFormat:@"%02i.png", spot_count];
    pinView.image = [UIImage imageNamed:image_name];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [button addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
    [button setTag: [((SpotAnnotation *)annotation).cluster_index intValue]];
    pinView.rightCalloutAccessoryView = button;

    return pinView;    
}

- (IBAction) btnClickRecenter:(id)sender {
    [self centerOnUserLocation];
}


#pragma mark -
#pragma mark map methods

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if ([self.from_list boolValue] == false) {
        [self runSearch];
    }
    else {
        [self showFoundSpots];
        self.from_list = [NSNumber numberWithBool:false];
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if([view.annotation isKindOfClass:[MKUserLocation class]])
        return;

    SpotAnnotation *annotation = (SpotAnnotation *)view.annotation;
    if (annotation.spots.count > 1) {
        self.cluster_spots_to_display = annotation.spots;
        [self performSegueWithIdentifier:@"cluster_details" sender:nil];
        [map_view deselectAnnotation:annotation animated:false];
    }
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation 
{
    [self centerOnUserLocation];
}

#pragma mark -

-(void)centerOnUserLocation {
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

        AnnotationCluster *selected_cluster = [self.current_clusters objectAtIndex:[sender tag]];
        
        [details setSpot:[selected_cluster.spots objectAtIndex:0]];
    }
    else if ([[segue identifier] isEqualToString:@"spot_list"]) {
        UINavigationController *nav = segue.destinationViewController;
        ListViewController *destination = [[nav viewControllers] objectAtIndex:0];      
        
        NSMutableArray *all_spots = [[NSMutableArray alloc] init];
        for (int index = 0; index < self.current_clusters.count; index++) {
            AnnotationCluster *cluster = [self.current_clusters objectAtIndex:index];
            [all_spots addObjectsFromArray:cluster.spots];
        }
       
        destination.current_spots = all_spots;       
        destination.map_region = [self.map_view region];
        destination.map_view = self.map_view;
    }
    else if ([[segue identifier] isEqualToString:@"cluster_details"]) {
        ListViewController *destination = segue.destinationViewController;
        destination.current_spots = self.cluster_spots_to_display;
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

    if (self.current_spots.count > 0) {
        self.from_list = [NSNumber numberWithBool:true];
        [map_view setRegion:self.map_region animated: NO];

    }
    else {
        [map_view setShowsUserLocation:YES];
        self.from_list = [NSNumber numberWithBool:false];        
    }

//    NSLog(map_view.userLocation);
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

@end
