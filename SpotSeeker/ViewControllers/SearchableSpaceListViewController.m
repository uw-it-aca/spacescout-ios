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
