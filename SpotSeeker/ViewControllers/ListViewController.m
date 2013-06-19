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
    
    // Get GA tracker
    id tracker = [GAI sharedInstance].defaultTracker;
    NSString *className = [NSString stringWithFormat:@"List View (%@)", self.class];
    [tracker sendView:className];

    self.rest = [[REST alloc] init];
    self.rest.delegate = self;
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

-(void)viewWillAppear:(BOOL)animated {
    self.campus_picker_panel.hidden = true;
    [self setScreenTitleForCurrentCampus];
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
    Campus *current_campus = [Campus getCurrentCampus];
    
    if ([current_campus.search_key isEqualToString:campus.search_key]) {
        [self hideCampusChooser];
        return;
    }
    [Campus setCurrentCampus: campus];
    self.search_attributes = nil;
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app_delegate.search_preferences = nil;
    [self centerOnCampus:campus];
    [self setScreenTitleForCurrentCampus];

    [self runSearch];
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

    [self showLabstatsForSpace:row_spot inTableCell:cell];
    
    UILabel *location_description = (UILabel *)[cell viewWithTag:5];
    location_description.lineBreakMode = UILineBreakModeTailTruncation;
    
    NSString *description = [row_spot.extended_info objectForKey:@"location_description"];
    location_description.text = description;

    CGFloat image_bottom = spot_image.frame.origin.y + spot_image.frame.size.height;
    
    [location_description sizeToFit];
    CGRect frame = location_description.frame;

    CGFloat location_height = frame.size.height;
    
    location_description.frame = CGRectMake(frame.origin.x, image_bottom - location_height, frame.size.width, frame.size.height);
    
    return cell;
}

-(void)showLabstatsForSpace:(Space *)space inTableCell:(UITableViewCell *)cell {
    UIImageView *labstats_image = (UIImageView *)[cell viewWithTag:10];
    UILabel *available = (UILabel *)[cell viewWithTag:11];
    UILabel *slash = (UILabel *)[cell viewWithTag:12];
    UILabel *total = (UILabel *)[cell viewWithTag:13];
    
    if ([space.extended_info objectForKey:@"auto_labstats_total"]) {
        id raw_available_value = [space.extended_info objectForKey:@"auto_labstats_available"];
        if (raw_available_value == nil || ![space isOpenNow]) {
            available.text = @"--";
        }
        else {
            available.text = raw_available_value;
        
            if ([raw_available_value integerValue] == 0) {
                available.textColor = [UIColor redColor];
            }
            else {
                available.textColor = [UIColor greenColor];
            }
        }
        
        CGFloat slash_width = [@"/" sizeWithFont:available.font constrainedToSize:CGSizeMake(500.0, 500.0)].width;
        CGFloat available_width = [available.text sizeWithFont:available.font constrainedToSize:CGSizeMake(500.0, 500.0)].width;
        CGFloat available_left = available.frame.origin.x;
        CGFloat slash_left = available_left + available_width;
        
        slash.frame = CGRectMake(slash_left, slash.frame.origin.y, slash_width, slash.frame.size.height);
        
        CGFloat total_left = slash_left + slash_width;
        total.frame = CGRectMake(total_left, total.frame.origin.y, total.frame.size.width, total.frame.size.height);
        total.text = [space.extended_info objectForKey:@"auto_labstats_total"];
        
    }
    else {
        available.hidden = true;
        slash.hidden = true;
        total.hidden = true;
        labstats_image.hidden = true;
    }

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
