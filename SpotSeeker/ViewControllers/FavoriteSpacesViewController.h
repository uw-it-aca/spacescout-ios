//
//  FavoriteSpotsViewController.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Space.h"
#import "Favorites.h"
#import "ListViewController.h"
#import "OAuthLoginViewController.h"

@interface FavoriteSpacesViewController : ListViewController <UITableViewDelegate, UITableViewDataSource, SearchFinished, OAuthLogin, MovingFavorites> {
    NSArray *favorites;
}

- (IBAction) btnClickClose:(id)sender;

@property (nonatomic, retain) NSArray *favorites;
@property (nonatomic, retain) IBOutlet UIView *no_favorites;
@property (nonatomic) BOOL handling_login;
@property (nonatomic, retain) Favorites *favorites_interface;

@end
