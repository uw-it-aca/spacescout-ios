//
//  ListViewController.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REST.h"
#import "Space.h"
#import "SpaceDetailsViewController.h"
#import "MapViewController.h"
#import "SearchableSpaceListViewController.h"

@interface ListViewController : SearchableSpaceListViewController <UITableViewDelegate, UITableViewDataSource, RESTFinished, UIAlertViewDelegate> {
    IBOutlet UITableView *spot_table;
    Space *selected_spot;
    MKCoordinateRegion map_region;
}

-(void)sortSpots;

@property (nonatomic, retain) UITableView *spot_table;
@property (nonatomic, retain) Space *selected_spot;
@property (nonatomic) MKCoordinateRegion map_region;
@property (nonatomic, retain) REST *rest;
@property (nonatomic, retain) UIAlertView *alert;
@property (nonatomic, retain) NSMutableDictionary *requests;

- (IBAction) btnClickCampusSelected:(id)sender;


@end
