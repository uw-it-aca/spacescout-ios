//
//  SearchableIndexedTableFilterViewController.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "REST.h"
#import "SBJson.h"
#import "Campus.h"

@interface SearchableIndexedTableFilterViewController : ViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
    NSMutableDictionary *filter;
    IBOutlet UITableView *table_view;
    IBOutlet UISearchBar *search_bar;
    IBOutlet UIActivityIndicatorView *loading_spinner;
    UISearchDisplayController *search_display_controller;
    NSMutableDictionary *index_data;
    NSArray *search_results;
    UITableViewCell *search_bar_cell;
    NSNumber *did_cancel;
}

-(IBAction)btnClickCancel:(id)sender;

@property (nonatomic, retain) NSNumber *did_cancel;
@property (nonatomic, retain) NSMutableDictionary *index_data;
@property (nonatomic, retain) NSMutableDictionary *filter;
@property (nonatomic, retain) UITableView *table_view;
@property (nonatomic, retain) UISearchBar *search_bar;
@property (nonatomic, retain) UISearchDisplayController *search_display_controller;
@property (nonatomic, retain) NSArray *search_results;
@property (nonatomic, retain) UITableViewCell *search_bar_cell;
@property (nonatomic, retain) UIActivityIndicatorView *loading_spinner;
@property (nonatomic, retain) REST *rest;

@end
