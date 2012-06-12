//
//  MapFilterDetailsViewController.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapFilterDetailsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableDictionary *filter;
    IBOutlet UITableView *table_view;
    IBOutlet UILabel *screen_header;
    IBOutlet UILabel *screen_subheader;
}

//- (void) setFilter:(NSMutableDictionary *)filter;

@property (retain, nonatomic) IBOutlet UILabel *screen_header;
@property (retain, nonatomic) IBOutlet UILabel *screen_subheader;

@property (retain, nonatomic) NSMutableDictionary *filter;
@property (retain, nonatomic) UITableView *table_view;

@end
