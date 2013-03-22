//
//  ListViewController.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListViewController.h"

@implementation ListViewController

@synthesize spot_table;
@synthesize selected_spot;
@synthesize map_region;
@synthesize rest;
@synthesize alert;
@synthesize requests;

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
    self.rest = [[REST alloc] init];
    self.rest.delegate = self;
    if (self.current_spots.count < 1) {
        [self runSearch];
    }
    [self sortSpots];
    [self.spot_table reloadData];
    self.requests = [[NSMutableDictionary alloc] init];
	// Do any additional setup after loading the view.
}

-(void)viewDidDisappear:(BOOL)animated {
    for (NSNumber *key in self.requests) {
        ASIHTTPRequest *request = [self.requests objectForKey:key];
        [request cancel];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [self.spot_table reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];    
    // Release any retained subviews of the main view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"search_filter"]) {
        UINavigationController *nav_controller = segue.destinationViewController;
        MapFilterViewController *filter_vc = [nav_controller.childViewControllers objectAtIndex:0];
        filter_vc.delegate = (id <SearchFilters>)self;
    }
    else if ([[segue identifier] isEqualToString:@"show_details"]) {
        SpaceDetailsViewController *details = segue.destinationViewController;
        [details setSpot:self.selected_spot];
    }
    else if ([[segue identifier] isEqualToString:@"spot_map"]) {
        UINavigationController *nav = segue.destinationViewController;
        MapViewController *destination = [[nav viewControllers] objectAtIndex:0];      
        destination.current_spots = self.current_spots;
        destination.map_region = self.map_region;
        destination.search_attributes = self.search_attributes;
    }
}

#pragma mark -
#pragma mark campus selection

-(IBAction)btnClickCampusSelected:(id)sender {
    int row = [self.campus_picker selectedRowInComponent:0];
    Campus *campus = [[Campus getCampuses] objectAtIndex:row];
    [Campus setCurrentCampus: campus];
    self.search_attributes = nil;
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app_delegate.search_preferences = nil;
    
    [self hideCampusChooser];
}



#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)showRunningSearchIndicator {
    UIActivityIndicatorView *loading_spinner = (UIActivityIndicatorView *)[self.view viewWithTag:80];
    loading_spinner.color = [UIColor grayColor];
    loading_spinner.hidden = NO;    
}

-(void) searchCancelled {
    UIActivityIndicatorView *loading_spinner = (UIActivityIndicatorView *)[self.view viewWithTag:80];
    loading_spinner.hidden = YES;
}

-(void) showFoundSpaces {
    [self sortSpots];
    UIActivityIndicatorView *loading_spinner = (UIActivityIndicatorView *)[self.view viewWithTag:80];
    if (loading_spinner.hidden == NO && [self.current_spots count] == 0) {
        UIAlertView *_alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no search results title", nil) message:NSLocalizedString(@"no search results message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"no search results button", nil) otherButtonTitles:nil];
        self.alert = _alert;
        [self.alert show];

    }
    
    loading_spinner.hidden = YES;    

    [self.spot_table reloadData];
}

#pragma mark -
#pragma mark sorting methods

-(void)sortSpots {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MKUserLocation *user_location = delegate.user_location;
    
    for (spot in self.current_spots) {
        if (user_location == nil || user_location.location == nil) {
            spot.distance_from_user = nil;
        }
        else {
            CLLocation *spot_location = [[CLLocation alloc] initWithLatitude:[spot.latitude floatValue] longitude:[spot.longitude floatValue]];
            double meters = [spot_location distanceFromLocation:user_location.location];
            double miles = meters * 0.000621371192;
            spot.distance_from_user = [NSNumber numberWithFloat:miles];
        }
    }
 
    self.current_spots = [self.current_spots sortedArrayUsingSelector:@selector(compareToSpot:)];
}

#pragma mark -
#pragma mark table_view_methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.current_spots.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Space *row_spot = [self.current_spots objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"spot_list_display"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"spot_list_display"];
    }
 
    UIImageView *spot_image = (UIImageView *)[cell viewWithTag:20];
    UIActivityIndicatorView *loading_image = (UIActivityIndicatorView *)[cell viewWithTag:21];

            
    if ([row_spot.image_urls count]) {
        NSString *image_url = [row_spot.image_urls objectAtIndex:0];
                
        spot_image.hidden = TRUE;
        loading_image.hidden = FALSE;
        
        __weak ASIHTTPRequest *request = [rest getRequestForBlocksWithURL:image_url];
        [self.requests setObject:request forKey:[NSNumber numberWithInt:indexPath.row]];
        [request setCompletionBlock:^{
            bool update_image = false;
            for (NSIndexPath *path in tableView.indexPathsForVisibleRows) {
                if (path.row == indexPath.row) {
                    update_image = true;
                }
            }

            if (update_image) {
                UIImage *img = [[UIImage alloc] initWithData:[request responseData]];
                [spot_image setImage:img];    
                
                loading_image.hidden = TRUE;
                spot_image.hidden = FALSE;
            }
            @autoreleasepool {
                [self.requests removeObjectForKey:[NSNumber numberWithInt:indexPath.row]];
            }
        }];

        [request setFailedBlock:^{
            // the status code is 0 if we cancel the request
            if (request.responseStatusCode == 0) {
                return;
            }
            bool update_image = false;
            for (NSIndexPath *path in tableView.indexPathsForVisibleRows) {
                if (path.row == indexPath.row) {
                    update_image = true;
                }
            }
            
            if (update_image) {
                UIImage *no_image = [UIImage imageNamed:@"placeholder_noImage_bw.png"];
                [spot_image setImage:no_image];
                loading_image.hidden = TRUE;
                spot_image.hidden = FALSE;
            }
            @autoreleasepool {
                [self.requests removeObjectForKey:[NSNumber numberWithInt:indexPath.row]];
            }
        }];
        
        [request startAsynchronous];
    }
    else {
        UIImage *no_image = [UIImage imageNamed:@"placeholder_noImage_bw.png"];
        [spot_image setImage:no_image];
        loading_image.hidden = TRUE;
        spot_image.hidden = FALSE;
    }
    
    UILabel *distance_label = (UILabel *)[cell viewWithTag:3];
    UILabel *distance_value = (UILabel *)[cell viewWithTag:4];
        
    if (row_spot.distance_from_user != nil) {
        float distance = [row_spot.distance_from_user floatValue];
        if (distance > 1.0) {
            distance_value.text = [NSString stringWithFormat:@"%.01f", [row_spot.distance_from_user floatValue]];   
        }
        else {
            distance_value.text = [NSString stringWithFormat:@"%.02f", [row_spot.distance_from_user floatValue]];   
        }
    }
    else {
        distance_label.hidden = YES;
        distance_value.hidden = YES;
    }
    
    UILabel *spot_name = (UILabel *)[cell viewWithTag:1];
    spot_name.text = row_spot.name;
    
    UILabel *spot_type = (UILabel *)[cell viewWithTag:2];
    
    NSMutableArray *type_names = [[NSMutableArray alloc] init];
    for (NSString *type in row_spot.type) {
        NSString *string_key = [NSString stringWithFormat:@"Space type %@", type];
        
        NSString *type_name = NSLocalizedString(string_key, nil);
        [type_names addObject:type_name];
    }
    NSString *type_display = [type_names componentsJoinedByString:@", "];
    
    if (row_spot.capacity) {
        type_display = [NSString stringWithFormat:@"%@, seats %i", type_display, [row_spot.capacity intValue]];
    }
    spot_type.text = type_display;
  
    UILabel *location_description = (UILabel *)[cell viewWithTag:5];
    location_description.lineBreakMode = UILineBreakModeTailTruncation;
    
    NSString *description = [row_spot.extended_info objectForKey:@"location_description"];
    location_description.text = description;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    self.selected_spot = [self.current_spots objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"show_details" sender:nil];
}

#pragma mark -

-(void)requestFromREST:(ASIHTTPRequest *)request {
}

#pragma mark -
#pragma mark alert methods

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self performSegueWithIdentifier:@"search_filter" sender:self];
}

@end
