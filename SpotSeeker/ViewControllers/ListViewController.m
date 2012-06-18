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
    [self.spot_table reloadData];
	// Do any additional setup after loading the view.
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
        SpotDetailsViewController *details = segue.destinationViewController;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) showFoundSpots {
    [self.spot_table reloadData];
}

#pragma mark -
#pragma mark table_view_methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.current_spots.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Spot *row_spot = [self.current_spots objectAtIndex:indexPath.row];
    
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
        
        [request setCompletionBlock:^{
            UIImage *img = [[UIImage alloc] initWithData:[request responseData]];
            [spot_image setImage:img];    
            
            loading_image.hidden = TRUE;
            spot_image.hidden = FALSE;
            
        }];
        
        [request startAsynchronous];
    }
    
    UILabel *spot_name = (UILabel *)[cell viewWithTag:1];
    spot_name.text = row_spot.name;
    
    UILabel *spot_type = (UILabel *)[cell viewWithTag:2];
    spot_type.text = row_spot.type;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    self.selected_spot = [self.current_spots objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"show_details" sender:nil];
}

#pragma mark -

-(void)requestFromREST:(ASIHTTPRequest *)request {
}

@end
