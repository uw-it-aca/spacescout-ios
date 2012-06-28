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

@interface FavoriteSpacesViewController : ListViewController <UITableViewDelegate, UITableViewDataSource, SearchFinished> {
    NSArray *favorites;
}

- (IBAction) btnClickClose:(id)sender;

@property (nonatomic, retain) NSArray *favorites;

@end
