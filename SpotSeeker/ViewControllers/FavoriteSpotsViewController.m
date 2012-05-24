//
//  FavoriteSpotsViewController.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavoriteSpotsViewController.h"

@implementation FavoriteSpotsViewController

@synthesize favorites;

#pragma mark -
#pragma mark load spots

-(void)searchFinished:(NSArray *)spots {
    self.current_spots = spots;
    [self.spot_table reloadData];
}

#pragma mark -
#pragma mark viewcontroller loading

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.favorites = [Favorites getFavoritesIDList];
    NSMutableDictionary *id_lookup = [[NSMutableDictionary alloc] init];
    [id_lookup setObject:self.favorites forKey:@"id"];
    
    Spot *search_spot = [[Spot alloc] init];
    search_spot.delegate = self;
    [search_spot getListBySearch:id_lookup];
    self.spot = search_spot;
	// Do any additional setup after loading the view.
}

@end
