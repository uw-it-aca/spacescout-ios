//
//  FavoriteSpotsViewController.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavoriteSpacesViewController.h"

@implementation FavoriteSpacesViewController

@synthesize removed_space_id;
@synthesize favorites;
@synthesize favorites_interface;
@synthesize no_favorites;
@synthesize loading_favorites;
@synthesize handling_login;

- (IBAction)btnClickClose:(id)sender {   
    [self.side_menu showMenu];
}

#pragma mark - override swipe behavior

-(void)handleSwipe:(UISwipeGestureRecognizer *)gesture {
    [self btnClickClose:nil];
}

#pragma mark -
#pragma mark load spots

-(void)searchFinished:(NSArray *)spots {
    self.current_spots = self.spots_to_display = spots;
    [self sortSpots];
    if (self.current_spots.count > 0) {
        // Just to make sure we show the right thing on the details view -
        // if someone goes to favorites before zooming in, we don't have the global
        // favorites that would have set this.
        for (Space *space in spots) {
            space.is_favorite = TRUE;
        }
        [Favorites setLocalCacheFromFavoritesList:spots];
        [self.spot_table reloadData];
        self.no_favorites.hidden = YES;
        self.spot_table.hidden = NO;
    }
    else {
        self.spot_table.hidden = YES;
        self.no_favorites.hidden = NO;
    }
    self.loading_favorites.hidden = YES;
}

#pragma mark -
#pragma mark oauth login protocol

-(void)backButtonPressed:(id)sender {
    NSLog(@"Back?");
}

-(void)loginCancelled {
    self.handling_login = FALSE;
    [self dismissViewControllerAnimated:NO completion:^(void) {}];
}

-(void)loginComplete {
    self.handling_login = FALSE;
    [self dismissViewControllerAnimated:YES completion:^(void){}];
    self.favorites_interface = [[Favorites alloc] init];
    self.favorites_interface.moving_delegate = self;
    [self.favorites_interface moveFavoritesToServerFavorites];
}

-(void)movingFinished {
    [self fetchFavorites];
}

#pragma mark -
#pragma mark viewcontroller loading

-(void)viewWillAppear:(BOOL)animated {
    NSMutableArray *new_display = [[NSMutableArray alloc] init];
    for (Space * test in self.current_spots) {
        // If someone unfavorites off of the favorites list, hide it right away.
        if (![test.remote_id isEqualToString:self.removed_space_id]) {
            [new_display addObject:test];
        }
    }
    self.spots_to_display = new_display;
    [self.spot_table reloadData];
}

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
        
 //       [self.navigationController presentViewController:auth_vc animated:YES completion:^(void){}];
        [self presentViewController:auth_vc animated:YES completion:^(void) {}];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.side_menu = [[SideMenu alloc] init];
    [self.side_menu setOpeningViewController:self];
    [self.side_menu addSwipeToOpenMenuToView:self.view];
    [self.spot_table reloadData];

}

- (void)fetchFavorites {
    Space *search_spot = [[Space alloc] init];
    search_spot.delegate = self;
    [search_spot getListByFavorites];
    self.spot = search_spot;
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // show_details
    if ([[segue identifier] isEqualToString:@"show_details"]) {
        SpaceDetailsViewController *destination = (SpaceDetailsViewController *)[segue destinationViewController];
        destination.opening_view_controller_favorites = self;
    }
    [super prepareForSegue:segue sender:sender];
}

-(void)btnClickDiscoverSpaces:(id)sender {
    UIViewController *root = [SideMenu rootVCForVC:self];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.35;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromLeft;
    
    UIView *containerView = self.view.window;
    [containerView.layer addAnimation:transition forKey:nil];
    
    [root dismissViewControllerAnimated:YES completion:^(void) {}];
}

- (NSUInteger)supportedInterfaceOrientations
{
    //decide number of origination tob supported by Viewcontroller.
    return UIInterfaceOrientationMaskPortrait;
}

@end
