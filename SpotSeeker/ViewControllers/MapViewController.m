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
@synthesize current_annotations;
@synthesize selected_cluster;
@synthesize alert;
@synthesize original_campus;

extern const int meters_per_latitude;

-(void)showRunningSearchIndicator {
    UIActivityIndicatorView *loading_spinner = (UIActivityIndicatorView *)[self.view viewWithTag:80];
    loading_spinner.hidden = NO;    
}

-(void)searchCancelled {
    UIActivityIndicatorView *loading_spinner = (UIActivityIndicatorView *)[self.view viewWithTag:80];
    loading_spinner.hidden = YES;
}

-(void) showFoundSpaces {
    if (self.starting_in_search) {
        return;
    }
    
    UIActivityIndicatorView *loading_spinner = (UIActivityIndicatorView *)[self.view viewWithTag:80];
    
    bool expand_map_on_demand = !loading_spinner.hidden;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([delegate.has_hidden_map_tooltip boolValue] == false) {
        expand_map_on_demand = true;
    }

    if (loading_spinner.hidden == NO && [self.current_spots count] == 0) {
        UIAlertView *_alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no search results title", nil) message:NSLocalizedString(@"no search results message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"no search results button", nil) otherButtonTitles:nil];
        self.alert = _alert;
        [self.alert show];
    }
    loading_spinner.hidden = YES;
    NSArray *annotation_groups = [AnnotationCluster createClustersFromSpots:self.current_spots andMap:map_view];
   
    NSMutableArray *next_spots = [[NSMutableArray alloc] init];
    NSMutableDictionary *keeper_ids = [[NSMutableDictionary alloc] init];
    
    CLLocation *map_center_location = [[CLLocation alloc] initWithLatitude:map_view.centerCoordinate.latitude longitude:map_view.centerCoordinate.longitude];
    CLLocationCoordinate2D closest_to_user = CLLocationCoordinate2DMake(0.00, 0.00);
    float closest_cluster_distance = MAXFLOAT;
    
    for (int index = 0; index < annotation_groups.count; index++) { 
        AnnotationCluster *cluster = [annotation_groups objectAtIndex:index];
        CLLocationCoordinate2D annotationCoord;
        annotationCoord.latitude = [cluster.display_latitude floatValue];
        annotationCoord.longitude = [cluster.display_longitude floatValue];

        CLLocation *spot_location = [[CLLocation alloc] initWithLatitude:annotationCoord.latitude longitude:annotationCoord.longitude];
        double meters = [spot_location distanceFromLocation:map_center_location];

        if (meters < closest_cluster_distance) {
            closest_to_user = annotationCoord;
            closest_cluster_distance = meters;
        }       
       
        Space *first_in_group = [cluster.spots objectAtIndex:0];
        SpaceAnnotation *annotationPoint = [[SpaceAnnotation alloc] init];
        annotationPoint.coordinate = annotationCoord;
        annotationPoint.spots = cluster.spots;
        annotationPoint.title = [first_in_group name];
        
        NSMutableArray *type_names = [[NSMutableArray alloc] init];
        for (NSString *type in first_in_group.type) {
            NSString *string_key = [NSString stringWithFormat:@"Space type %@", type];
            
            NSString *type_name = NSLocalizedString(string_key, nil);
            [type_names addObject:type_name];
        }
        NSString *all_types = [type_names componentsJoinedByString:@", "];
        
        annotationPoint.subtitle = [NSString stringWithFormat:@"%@", all_types];
        if (first_in_group.capacity != nil) {
            annotationPoint.subtitle = [annotationPoint.subtitle stringByAppendingFormat:@", seats %@", first_in_group.capacity];            
        }
        annotationPoint.cluster_index = [NSNumber numberWithInt:index];
        
        NSString *lookup_key = [annotationPoint getLookupKey];
        SpaceAnnotation *existing = [self.current_annotations objectForKey:lookup_key];
        
        if (existing) {
            existing.spots = annotationPoint.spots;
            existing.title = annotationPoint.title;
            existing.cluster_index = annotationPoint.cluster_index;
            [keeper_ids setObject:existing forKey:[existing getLookupKey]];
        }
        else {
            [next_spots addObject:annotationPoint];
        }
    }


    if (annotation_groups.count) {
        CGPoint closest_point = [map_view convertCoordinate:closest_to_user toPointToView:nil];
        
        if (closest_point.x < 0 || closest_point.y < 0 || closest_point.x > map_view.frame.size.width || closest_point.y > map_view.frame.size.height) {
            if (expand_map_on_demand) {
                MKCoordinateRegion region;
                region.center.latitude = (closest_to_user.latitude + map_view.centerCoordinate.latitude) / 2;
                region.center.longitude = (closest_to_user.longitude + map_view.centerCoordinate.longitude) / 2;
                
                NSString *app_path = [[NSBundle mainBundle] bundlePath];
                NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
                NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
                
                float map_padding = [[plist_values objectForKey:@"map_view_offscreen_space_padding"] floatValue];
                
                region.span.latitudeDelta = fabs((closest_to_user.latitude - map_view.centerCoordinate.latitude) * map_padding);
                region.span.longitudeDelta = fabs((closest_to_user.longitude - map_view.centerCoordinate.longitude) * map_padding);
                                
                MKCoordinateRegion scaled = [map_view regionThatFits:region];
      
                [map_view setRegion:scaled];
            }
        }
    }
    
    NSMutableArray *remove_me = [[NSMutableArray alloc] init];
    for (NSString *key in self.current_annotations) {
        SpaceAnnotation *test_annotation = [keeper_ids objectForKey:key];
        if (test_annotation == nil) {
            [remove_me addObject:key];
        }
    }
    
    for (int index = 0; index < [remove_me count]; index++) {
        NSString *key = [remove_me objectAtIndex:index];
        [self.map_view removeAnnotation:[self.current_annotations objectForKey:key]];
        [self.current_annotations removeObjectForKey:key];
    }
    
    for (int index = 0; index < [next_spots count]; index++) {
        SpaceAnnotation *add_me = [next_spots objectAtIndex:index];
        [self.map_view addAnnotation:add_me];
        [self.current_annotations setObject:add_me forKey:[add_me getLookupKey]];
    }
    self.current_clusters = annotation_groups;
}


- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation {
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if (![annotation isKindOfClass:[SpaceAnnotation class]])
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

    SpaceAnnotation *actual = (SpaceAnnotation *)annotation;
    
    long int spot_count = actual.spots.count;
    if (spot_count > 30) {
        spot_count = 30;
    }

    pinView.canShowCallout = false;
    /*
    if (spot_count > 1) {
        pinView.canShowCallout = false;
    }
    else {
        pinView.canShowCallout = true;
    }
     */
    
    NSString *image_name = [NSString stringWithFormat:@"pin%02li.png", spot_count];
    pinView.image = [UIImage imageNamed:image_name];
    
    // XXX - This is the distance from the center of the image to the "point" of the pin drop. Needs to be updated with the images.
    pinView.centerOffset = CGPointMake(5, -20);
        
    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [button addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
    pinView.rightCalloutAccessoryView = button;

    return pinView;    
}

- (IBAction) btnClickRecenter:(id)sender {
    [self centerOnUserLocation];
}

#pragma mark -
#pragma mark alert methods

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self performSegueWithIdentifier:@"search_filter" sender:self];
}

#pragma mark -
#pragma mark map methods

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if ([self.from_list boolValue] == false) {
        [self hideTipView];
        [self runSearch];
    }
    else {
        [self showFoundSpaces];
    }
}

-(void)hideTipView {
    if (loading) {
        return;
    }
    if (showing_tip_view) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        delegate.has_hidden_map_tooltip = [NSNumber numberWithBool:true];

        UIView *tips = [self.view viewWithTag:10];
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{   
                             tips.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             tips.hidden = true;
                         }
         ];

    }
    showing_tip_view = false;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    loading = false;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if([view.annotation isKindOfClass:[MKUserLocation class]])
        return;

    SpaceAnnotation *annotation = (SpaceAnnotation *)view.annotation;
    self.selected_cluster = annotation.spots;
    if (annotation.spots.count > 1) {
        self.cluster_spots_to_display = annotation.spots;
        [self performSegueWithIdentifier:@"cluster_details" sender:nil];
        [map_view deselectAnnotation:annotation animated:false];
    }
    else {
        [self performSegueWithIdentifier:@"show_details" sender:nil];
        [map_view deselectAnnotation:annotation animated:false];
    }
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation 
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.user_location = userLocation;
    
    if (has_centered_on_location) {
        return;
    }
    has_centered_on_location = true;

    [self centerOnUserLocation];
}

#pragma mark -

- (void)showDetails:(id)sender {
    [self performSegueWithIdentifier:@"show_details" sender: sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"search_filter"]) {
        MapFilterViewController *filter_vc = (MapFilterViewController *)segue.destinationViewController;
        filter_vc.user_latitude = [[NSNumber alloc] initWithDouble: self.map_view.centerCoordinate.latitude];
        filter_vc.user_longitude = [[NSNumber alloc] initWithDouble: self.map_view.centerCoordinate.longitude];
        filter_vc.user_distance = [[NSNumber alloc] initWithDouble: map_view.region.span.latitudeDelta * meters_per_latitude ];
        filter_vc.delegate = (id <SearchFilters>)self;
    }
    else if ([[segue identifier] isEqualToString:@"show_details"]) {
        SpaceDetailsViewController *details = segue.destinationViewController;

        [details setSpot:[self.selected_cluster objectAtIndex:0]];
    }
    else if ([[segue identifier] isEqualToString:@"spot_list"]) {
        UINavigationController *nav = segue.destinationViewController;
        ListViewController *destination = [[nav viewControllers] objectAtIndex:0];      

        if (self.is_running_search) {
            self.current_map_list_ui_view_controller = destination;
            destination.starting_in_search = true;
        }

        
        NSMutableArray *all_spots = [[NSMutableArray alloc] init];
        for (int index = 0; index < self.current_clusters.count; index++) {
            AnnotationCluster *cluster = [self.current_clusters objectAtIndex:index];
            [all_spots addObjectsFromArray:cluster.spots];
        }
       
        destination.current_spots = all_spots;
        destination.map_region = [self.map_view region];
        destination.map_view = self.map_view;
        destination.search_attributes = self.search_attributes;

    }
    else if ([[segue identifier] isEqualToString:@"cluster_details"]) {
        ListViewController *destination = segue.destinationViewController;
        destination.current_spots = self.cluster_spots_to_display;
    }
    else if ([[segue identifier] isEqualToString:@"more_view"]) {
        original_campus = [Campus getCurrentCampus];
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

-(void)viewDidAppear:(BOOL)animated {
    Campus *current_campus = [Campus getCurrentCampus];
    Campus *next_campus = [Campus getNextCampus];
    
    if (next_campus && (!current_campus || current_campus.search_key != next_campus.search_key)) {
        [Campus setCurrentCampus:next_campus];
        current_campus = next_campus;
        [Campus clearNextCampus];
        self.search_attributes = nil;
        AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        app_delegate.search_preferences = nil;
        [self centerOnCampus:current_campus];
        [self setScreenTitleForCurrentCampus];
    }
    if (self.starting_in_search) {
        [self showRunningSearchIndicator];
    }
    
    if (self.current_spots.count > 0) {
        self.from_list = [NSNumber numberWithBool:true];
        [map_view setShowsUserLocation:YES];
        
        [map_view setRegion:self.map_region animated: NO];
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(clearFromList:) userInfo:nil repeats:FALSE];
    }
    else {
        [map_view setShowsUserLocation:YES];
        self.from_list = [NSNumber numberWithBool:false];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get GA tracker
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"Map View"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([delegate.has_hidden_map_tooltip boolValue] == true) {
        UIView *tips = [self.view viewWithTag:10];
        tips.hidden = true;
    }
    
    UIActivityIndicatorView *loading_spinner = (UIActivityIndicatorView *)[self.view viewWithTag:80];
    loading_spinner.color = [UIColor grayColor];
    
    showing_tip_view = true;
    loading = true;
    has_centered_on_location = false;
    self.current_annotations = [[NSMutableDictionary alloc] init];
    map_view.delegate = self;

}

-(void)clearFromList:(NSTimer *)timer {
    self.from_list = [NSNumber numberWithBool:false];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
