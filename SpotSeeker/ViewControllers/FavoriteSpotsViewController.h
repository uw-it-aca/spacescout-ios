//
//  FavoriteSpotsViewController.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Spot.h"
#import "Favorites.h"
#import "ListViewController.h"

@interface FavoriteSpotsViewController : ListViewController <UITableViewDelegate, UITableViewDataSource, SearchFinished> {
    NSArray *favorites;
}

@property (nonatomic, retain) NSArray *favorites;

@end
