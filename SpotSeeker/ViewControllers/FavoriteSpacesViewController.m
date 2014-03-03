//
//  FavoriteSpotsViewController.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavoriteSpacesViewController.h"

@implementation FavoriteSpacesViewController

@synthesize favorites;
@synthesize favorites_interface;
@synthesize no_favorites;
@synthesize handling_login;

- (IBAction)btnClickClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void) {}];
}


#pragma mark -
#pragma mark load spots

-(void)searchFinished:(NSArray *)spots {
    self.current_spots = spots;
    [self sortSpots];
    if (self.current_spots.count > 0) {
        [self.spot_table reloadData];
    }
    else {
        self.spot_table.hidden = YES;
        self.no_favorites.hidden = NO;
    }
}

#pragma mark -
#pragma mark oauth login protocol

-(void)loginCancelled {
    self.handling_login = FALSE;
    [self dismissViewControllerAnimated:NO completion:^(void) {}];
}

-(void)loginComplete {
    self.handling_login = FALSE;
    self.favorites_interface = [[Favorites alloc] init];
    self.favorites_interface.moving_delegate = self;
    [self.favorites_interface moveFavoritesToServerFavorites];
}

-(void)movingFinished {
    [self fetchFavorites];
}

#pragma mark -
#pragma mark viewcontroller loading

- (void)viewDidAppear:(BOOL)animated {
    if (self.handling_login) {
        return;
    }
    if ([REST hasPersonalOAuthToken]) {
        [self fetchFavorites];
    }
    else {
        self.handling_login = TRUE;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
        
        OAuthLoginViewController *auth_vc = [storyboard instantiateViewControllerWithIdentifier:@"OAuth_Login"];
        auth_vc.delegate = self;
        
        [self presentViewController:auth_vc animated:YES completion:^(void) {}];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}



- (void)fetchFavorites {   
    Space *search_spot = [[Space alloc] init];
    search_spot.delegate = self;
    [search_spot getListByFavorites];
    self.spot = search_spot;
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    //decide number of origination tob supported by Viewcontroller.
    return UIInterfaceOrientationMaskPortrait;
}

@end
