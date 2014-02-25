//
//  SearchableSpotListViewController.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/24/12.
//  Copyright (c) 2012, 2013 University of Washington. All rights reserved.
//

#import "SearchableSpaceListViewController.h"


@implementation SearchableSpaceListViewController
@synthesize map_view;
@synthesize search_attributes;
@synthesize spot;
@synthesize current_spots;
@synthesize alert;
@synthesize is_running_search;
@synthesize current_map_list_ui_view_controller;
@synthesize starting_in_search;

int const meters_per_latitude = 111 * 1000;
bool first_search = false;

-(void) runSearch {
    self.is_running_search = true;
    if (search_attributes == nil) {
        search_attributes = [[NSMutableDictionary alloc] init];
    }
    
    Reachability *r = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == NotReachable) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate showNoNetworkAlert];
        [self searchCancelled];
        return;
    }

    [search_attributes setValue:[NSArray arrayWithObject:@"true"] forKey:@"expand_radius"];    
    [search_attributes setValue:[NSArray arrayWithObject:[NSNumber numberWithInt:0]] forKey:@"limit"];
    if ([search_attributes objectForKey:@"open_at"] == nil && [search_attributes objectForKey:@"open_until"] == nil) {
        [search_attributes setValue:[NSArray arrayWithObjects:@"1", nil] forKey:@"open_now"];
    }
    [search_attributes setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", map_view.centerCoordinate.latitude], nil] forKey:@"center_latitude"];
    [search_attributes setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", map_view.centerCoordinate.longitude], nil] forKey:@"center_longitude"];
    
    Campus *current = [Campus getCurrentCampus];
    NSArray *campus_param = [[NSArray alloc] initWithObjects:current.search_key, nil];
    [search_attributes setValue:campus_param forKey:@"extended_info:campus"];

    
    int meters = map_view.region.span.latitudeDelta * meters_per_latitude;
    
    if (meters > 10000 && first_search == false) {
        [self searchCancelled];
        return;
    }
    
    [search_attributes setValue:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%i", meters], nil] forKey:@"distance"];
    
    Space *_spot = [Space alloc];
    self.spot = _spot;
    [self.spot getListBySearch:search_attributes];
    
    [self.spot setDelegate:self];
    first_search = true;
}

-(void) runSearchWithAttributes:(NSMutableDictionary *)attributes {
    self.search_attributes = attributes;
    [self runSearch];
    
    // GA tracking of filters
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    for (id key in search_attributes) {
        for (id value in [search_attributes objectForKey:key]) {
            if (![key isEqualToString:@"center_latitude"] &&
                ![key isEqualToString:@"center_longitude"] &&
                ![key isEqualToString:@"limit"] &&
                ![key isEqualToString:@"expand_radius"] &&
                ![key isEqualToString:@"distance"] &&
                ![key isEqualToString:@"extended_info:campus"]) {
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Filters"
                                                                      action:[NSString stringWithFormat:@"%@-%@", [search_attributes objectForKey:@"extended_info:campus"][0], key]
                                                                       label:value
                                                                       value:nil] build]];
                //NSLog(@"campus = %@ key=%@ value=%@", [search_attributes objectForKey:@"extended_info:campus"][0], key, value);
            }
        }
    }
    
}

-(void) searchFinished:(NSArray *)spots {
    self.is_running_search = false;
    self.starting_in_search = false;
    if (self.current_map_list_ui_view_controller) {
        [self.current_map_list_ui_view_controller searchFinished:spots];
        return;
    }
    self.current_spots = spots;
    [self showFoundSpaces];
}

-(void)searchCancelled {
    // This should be implemented in the subclasses
}

-(void)showFoundSpaces {
    // Must be implemented in subclasses...
}

#pragma mark -
#pragma mark campus selection

-(void)setScreenTitleForCurrentCampus {
    NSString *className = [NSString stringWithFormat:@"%@", self.class];
    if ([className isEqual: @"FavoriteSpacesViewController"]) { // This is the one case where a ListView shouldn't show the campus name
        self.title = @"Favorites";
    } else {
        self.title = [Campus getCurrentCampus].screen_title;
    }
}

#pragma mark -

-(void)centerOnUserLocation {
    if (map_view.userLocation.location == nil) {
        Campus *current_campus = [Campus getCurrentCampus];
        [self centerOnCampus:current_campus];
        return;
    }
    else {
        MKCoordinateRegion mapRegion;
        mapRegion.center = map_view.userLocation.coordinate;
        mapRegion.span.latitudeDelta = 0.005;
        mapRegion.span.longitudeDelta = 0.005;
        
        [map_view setRegion:mapRegion animated: YES];
    }
}

-(void)centerOnCampus: (Campus *)campus {
    MKCoordinateRegion mapRegion;
    mapRegion.center =  CLLocationCoordinate2DMake([campus getLatitude], [campus getLongitude]);
    
    mapRegion.span.latitudeDelta = [campus getLatitudeDelta];
    mapRegion.span.longitudeDelta = [campus getLongitudeDelta];
    
    [map_view setRegion:mapRegion animated: NO];
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [self setScreenTitleForCurrentCampus];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
