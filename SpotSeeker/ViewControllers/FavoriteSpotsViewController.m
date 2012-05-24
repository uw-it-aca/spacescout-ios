//
//  FavoriteSpotsViewController.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavoriteSpotsViewController.h"

@implementation FavoriteSpotsViewController

@synthesize spots_table;
@synthesize favorites;
@synthesize spot;
@synthesize spot_list;

#pragma mark -
#pragma mark table methods

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.spot_list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Spot *row_spot = [self.spot_list objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"spot"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"spot"];
    }
    
    UILabel *spot_name = (UILabel *)[cell viewWithTag:1];
    spot_name.text = row_spot.name;
    return cell;

}

#pragma mark -
#pragma mark load spots

-(void)searchFinished:(NSArray *)spots {
    self.spot_list = spots;
    [self.spots_table reloadData];
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
