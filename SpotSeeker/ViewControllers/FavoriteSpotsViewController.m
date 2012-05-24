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

#pragma mark -
#pragma mark table methods

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favorites.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    Spot *row_spot = [self.favorites objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"spot"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"spot"];
    }
    
    UILabel *spot_name = (UILabel *)[cell viewWithTag:1];
    spot_name.text = @"Still need to fetch spot info";
    return cell;

}

#pragma mark -
#pragma mark viewcontroller loading

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.favorites = [Favorites getFavoritesList];
	// Do any additional setup after loading the view.
}

@end
