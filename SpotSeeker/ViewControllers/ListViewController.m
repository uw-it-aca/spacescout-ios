//
//  ListViewController.m
//  SpotSeeker
//
//  Copyright 2012, 2013 UW Information Technology, University of Washington
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


#import "ListViewController.h"

@implementation ListViewController

@synthesize spot_table;
@synthesize selected_spot;
@synthesize map_region;
@synthesize rest;
@synthesize alert;
@synthesize requests;
@synthesize original_campus;

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
    
    [self.side_menu addSwipeToOpenMenuToView:self.view];
    // Get GA tracker
    id tracker = [GAI sharedInstance].defaultTracker;
    NSString *className = [NSString stringWithFormat:@"List View (%@)", self.class];
    [tracker set:kGAIScreenName value:className];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    self.rest = [[REST alloc] init];
    self.rest.delegate = self;
    [self sortSpots];
    self.requests = [[NSMutableDictionary alloc] init];
    
    if (self.starting_in_search) {
        [self showRunningSearchIndicator];
    }
    
	// Do any additional setup after loading the view.
}

-(void)viewDidDisappear:(BOOL)animated {
    for (NSNumber *key in self.requests) {
        ASIHTTPRequest *request = [self.requests objectForKey:key];
        [request cancel];
    }
}

-(void)viewWillAppear:(BOOL)animated {
 //GONE   self.campus_picker_panel.hidden = true;
    // do something about changed campus!!!
    [self setScreenTitleForCurrentCampus];
    
    [self.spot_table reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [self.spot_table reloadData];

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
        
        [self runSearch];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];    
    // Release any retained subviews of the main view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"search_filter"]) {
        MapFilterViewController *filter_vc = (MapFilterViewController *)segue.destinationViewController;
        filter_vc.delegate = (id <SearchFilters>)self;
    }
    else if ([[segue identifier] isEqualToString:@"show_details"]) {
        SpaceDetailsViewController *details = segue.destinationViewController;
        [details setSpot:self.selected_spot];
    }
    else if ([[segue identifier] isEqualToString:@"spot_map"]) {
        UINavigationController *nav = segue.destinationViewController;
        MapViewController *destination = [[nav viewControllers] objectAtIndex:0];
        
        if (self.is_running_search) {
            self.current_map_list_ui_view_controller = destination;
            destination.starting_in_search = true;
        }

        destination.current_spots = self.current_spots;
        destination.map_region = self.map_region;
        destination.search_attributes = self.search_attributes;
    }
    else if ([[segue identifier] isEqualToString:@"more_view"]) {
        original_campus = [Campus getCurrentCampus];
    }
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
    if (self.starting_in_search) {
        return 0;
    }
    return self.spots_to_display.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Space *row_spot = [self.spots_to_display objectAtIndex:indexPath.row];
    
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
        [self.requests setObject:request forKey:[NSNumber numberWithLong:indexPath.row]];
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
                [self.requests removeObjectForKey:[NSNumber numberWithLong:indexPath.row]];
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
                [self.requests removeObjectForKey:[NSNumber numberWithLong:indexPath.row]];
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
    location_description.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSString *description = [row_spot.extended_info objectForKey:@"location_description"];
    location_description.text = description;

    CGFloat image_bottom = spot_image.frame.origin.y + spot_image.frame.size.height;

    // SPOT-952
    CGFloat original_width = location_description.frame.size.width;
    [location_description sizeToFit];
    CGRect frame = location_description.frame;

    CGFloat location_height = frame.size.height;
    
    location_description.frame = CGRectMake(frame.origin.x, image_bottom - location_height, original_width, frame.size.height);
    
    return cell;
}

-(void)showLabstatsForSpace:(Space *)space inTableCell:(UITableViewCell *)cell {
    UIImageView *labstats_image = (UIImageView *)[cell viewWithTag:10];
    UILabel *available = (UILabel *)[cell viewWithTag:11];
    UILabel *slash = (UILabel *)[cell viewWithTag:12];
    UILabel *total = (UILabel *)[cell viewWithTag:13];
    
    if ([space.extended_info objectForKey:@"auto_labstats_total"] && [[space.extended_info objectForKey:@"auto_labstats_total"] integerValue] > 0) {
        
        NSString *app_path = [[NSBundle mainBundle] bundlePath];
        NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
        NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
        
        float avail_redtext_red_value = [[plist_values objectForKey:@"labstats_avail_redtext_red"] floatValue];
        float avail_redtext_green_value = [[plist_values objectForKey:@"labstats_avail_redtext_green"] floatValue];
        float avail_redtext_blue_value = [[plist_values objectForKey:@"labstats_avail_redtext_blue"] floatValue];
        
        UIColor *avail_redtext_color = [UIColor colorWithRed:avail_redtext_red_value / 255.0 green:avail_redtext_green_value / 255.0 blue:avail_redtext_blue_value / 255.0 alpha:1.0];
        
        float avail_greentext_red_value = [[plist_values objectForKey:@"labstats_avail_greentext_red"] floatValue];
        float avail_greentext_green_value = [[plist_values objectForKey:@"labstats_avail_greentext_green"] floatValue];
        float avail_greentext_blue_value = [[plist_values objectForKey:@"labstats_avail_greentext_blue"] floatValue];
        
        UIColor *avail_greentext_color = [UIColor colorWithRed:avail_greentext_red_value / 255.0 green:avail_greentext_green_value / 255.0 blue:avail_greentext_blue_value / 255.0 alpha:1.0];

        id raw_available_value = [space.extended_info objectForKey:@"auto_labstats_available"];
        if (raw_available_value == nil || ![space isOpenNow]) {
            available.text = @"--";
        }
        else {
            available.text = raw_available_value;
        
            if ([raw_available_value integerValue] == 0) {
                available.textColor = avail_redtext_color;
            }
            else {
                available.textColor = avail_greentext_color;
            }
        }
        
        CGFloat slash_width = [@"/" boundingRectWithSize:CGSizeMake(500.0, 500.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: available.font } context:nil].size.width;

        CGFloat available_width = [available.text boundingRectWithSize:CGSizeMake(500.0, 500.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: available.font } context:nil].size.width;

        CGFloat available_left = available.frame.origin.x;
        CGFloat slash_left = available_left + available_width;
        
        slash.frame = CGRectMake(slash_left, slash.frame.origin.y, slash_width, slash.frame.size.height);
        
        CGFloat total_left = slash_left + slash_width;
        total.frame = CGRectMake(total_left, total.frame.origin.y, total.frame.size.width, total.frame.size.height);
        total.text = [space.extended_info objectForKey:@"auto_labstats_total"];
        
        available.hidden = false;
        slash.hidden = false;
        total.hidden = false;
        labstats_image.hidden = false;

    }
    else {
        available.hidden = true;
        slash.hidden = true;
        total.hidden = true;
        labstats_image.hidden = true;
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    self.selected_spot = [self.spots_to_display objectAtIndex:indexPath.row];
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
