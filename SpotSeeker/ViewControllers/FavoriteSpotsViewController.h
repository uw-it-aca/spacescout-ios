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

@interface FavoriteSpotsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SearchFinished> {
    UITableView *spots_table;
    NSArray *favorites;
    Spot *spot;
    NSArray *spot_list;
}

@property (nonatomic, retain) IBOutlet UITableView *spots_table;
@property (nonatomic, retain) NSArray *favorites;
@property (nonatomic, retain) Spot *spot;
@property (nonatomic, retain) NSArray *spot_list;

@end
