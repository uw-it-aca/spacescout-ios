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

@interface SearchableSpaceListViewController : UIViewController <SearchFinished> {
    MKMapView *map_view;
    NSMutableDictionary *search_attributes;
    NSArray *current_spots;
    Space *spot;
//    IBOutlet UIPickerView *campus_picker;
//    IBOutlet UIView *campus_picker_panel;


}

@property (nonatomic, retain) IBOutlet MKMapView *map_view;
@property (nonatomic, retain) NSMutableDictionary *search_attributes;
@property (nonatomic, retain) Space *spot;
@property (nonatomic, retain) NSArray *current_spots;
@property (nonatomic, retain) UIAlertView *alert;


-(void)runSearchWithAttributes:(NSMutableDictionary *)attributes;
-(void)showFoundSpaces;
-(void)searchCancelled;
-(void)runSearch;
// GONE -(void)hideCampusChooser;
-(void)centerOnUserLocation;
-(void)centerOnCampus: (Campus *)campus;
-(void)setScreenTitleForCurrentCampus;

@end
