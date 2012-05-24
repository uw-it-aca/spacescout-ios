//
//  ListViewController.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Spot.h"
#import "SpotDetailsViewController.h"
#import "MapViewController.h"

@interface ListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *spot_table;
    NSArray *spots;
    Spot *selected_spot;
    MKCoordinateRegion map_region;

}

@property (nonatomic, retain) NSArray *spots;
@property (nonatomic, retain) UITableView *spot_table;
@property (nonatomic, retain) Spot *selected_spot;
@property (nonatomic) MKCoordinateRegion map_region;

@end
