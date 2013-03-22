//
//  SearchableSpotListViewController.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Reachability.h"
#import "Space.h"
#import "AppDelegate.h"
#import "Campus.h"

@interface SearchableSpaceListViewController : UIViewController <SearchFinished, UIPickerViewDataSource, UIPickerViewDelegate> {
    MKMapView *map_view;
    NSMutableDictionary *search_attributes;
    NSArray *current_spots;
    Space *spot;
    IBOutlet UIPickerView *campus_picker;
    IBOutlet UIView *campus_picker_panel;


}

@property (nonatomic, retain) IBOutlet MKMapView *map_view;
@property (nonatomic, retain) NSMutableDictionary *search_attributes;
@property (nonatomic, retain) Space *spot;
@property (nonatomic, retain) NSArray *current_spots;
@property (nonatomic, retain) UIAlertView *alert;
@property (nonatomic, retain) UIPickerView *campus_picker;
@property (nonatomic, retain) UIView *campus_picker_panel;


-(void)runSearchWithAttributes:(NSMutableDictionary *)attributes;
-(void)showFoundSpaces;
-(void)searchCancelled;
-(void)runSearch;
-(void)hideCampusChooser;
-(void)centerOnUserLocation;
-(void)centerOnCampus: (Campus *)campus;
-(void)setScreenTitleForCurrentCampus;

@end
