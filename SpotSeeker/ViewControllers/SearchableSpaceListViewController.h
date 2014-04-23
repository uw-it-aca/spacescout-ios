//
//  SearchableSpotListViewController.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/24/12.
//  Copyright (c) 2012, 2013 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Reachability.h"
#import "Space.h"
#import "AppDelegate.h"
#import "Campus.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "SideMenu.h"

@interface SearchableSpaceListViewController : UIViewController <SearchFinished, UIGestureRecognizerDelegate> {
    MKMapView *map_view;
    NSMutableDictionary *search_attributes;
    NSArray *current_spots;
    Space *spot;
    Boolean is_running_search;
    // This is to handle switching between map and list during a search
    SearchableSpaceListViewController *current_map_list_ui_view_controller;
    // This tells us we're in the transition mentioned above - show the spinner
    Boolean starting_in_search;

//    IBOutlet UIPickerView *campus_picker;
//    IBOutlet UIView *campus_picker_panel;


}

@property (nonatomic, retain) IBOutlet MKMapView *map_view;
@property (nonatomic, retain) NSMutableDictionary *search_attributes;
@property (nonatomic, retain) Space *spot;
@property (nonatomic, retain) NSArray *current_spots;
@property (nonatomic, retain) UIAlertView *alert;
@property (nonatomic) Boolean is_running_search;
@property (nonatomic, retain) SearchableSpaceListViewController *current_map_list_ui_view_controller;
@property (nonatomic) Boolean starting_in_search;
@property (nonatomic, retain) SideMenu *side_menu;

-(void)addSwipeToOpenMenu;
-(void)runSearchWithAttributes:(NSMutableDictionary *)attributes;
-(void)showFoundSpaces;
-(void)searchCancelled;
-(void)runSearch;
// GONE -(void)hideCampusChooser;
-(void)centerOnUserLocation;
-(void)centerOnCampus: (Campus *)campus;
-(void)setScreenTitleForCurrentCampus;
- (IBAction) openNavigationMenu:(id)sender;


@end
