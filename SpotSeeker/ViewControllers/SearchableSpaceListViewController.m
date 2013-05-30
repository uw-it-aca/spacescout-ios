//
//  SearchableSpotListViewController.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchableSpaceListViewController.h"


@implementation SearchableSpaceListViewController
@synthesize map_view;
@synthesize search_attributes;
@synthesize spot;
@synthesize current_spots;
@synthesize alert;
@synthesize campus_picker;
@synthesize campus_picker_panel;

int const meters_per_latitude = 111 * 1000;
bool first_search = false;

-(void) runSearch {
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
}

-(void) searchFinished:(NSArray *)spots {
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
    self.title = [Campus getCurrentCampus].screen_title;
}

-(int)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[Campus getCampuses] count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray *campuses = [Campus getCampuses];
    Campus *campus = [campuses objectAtIndex:row];
    return campus.name;
}

-(IBAction)btnClickCampusChooser:(id)sender {
    NSArray *campuses = [Campus getCampuses];
    int selected_index;
    Campus *current = [Campus getCurrentCampus];
    
    for (int i = 0; i < [campuses count]; i++) {
        Campus *campus = [campuses objectAtIndex:i];
        if ([campus.search_key isEqualToString:current.search_key]) {
            selected_index = i;
            break;
        }
    }
    [self showCampusChooser];
    
    [self.campus_picker selectRow:selected_index inComponent:0 animated:false];
}



-(void)showCampusChooser {
    int height = self.campus_picker_panel.frame.size.height;
    int width = self.campus_picker_panel.frame.size.width;
    int starting_y = self.campus_picker_panel.frame.origin.y;
    
    int full_height = self.view.frame.size.height;
    
    self.campus_picker_panel.frame = CGRectMake(0, full_height, width, height);
    
    self.campus_picker_panel.hidden = false;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.campus_picker_panel.frame = CGRectMake(0, starting_y, width, height);
                     }
                     completion:^(BOOL finished){
                     }];
    
}

-(void)hideCampusChooser {
    int full_height = self.view.frame.size.height;
    int height = self.campus_picker_panel.frame.size.height;
    int width = self.campus_picker_panel.frame.size.width;
    int starting_y = self.campus_picker_panel.frame.origin.y;
    
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.campus_picker_panel.frame = CGRectMake(0, full_height, width, height);
                     }
                     completion:^(BOOL finished){
                         self.campus_picker_panel.hidden = true;
                         self.campus_picker_panel.frame = CGRectMake(0, starting_y, width, height);
                     }];
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
