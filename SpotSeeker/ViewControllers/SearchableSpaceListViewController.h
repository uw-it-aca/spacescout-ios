//
//  SearchableSpotListViewController.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Space.h"

@interface SearchableSpaceListViewController : UIViewController <SearchFinished> {
    MKMapView *map_view;
    NSMutableDictionary *search_attributes;
    NSArray *current_spots;
    Space *spot;

}

@property (nonatomic, retain) IBOutlet MKMapView *map_view;
@property (nonatomic, retain) NSMutableDictionary *search_attributes;
@property (nonatomic, retain) Space *spot;
@property (nonatomic, retain) NSArray *current_spots;

-(void)runSearchWithAttributes:(NSMutableDictionary *)attributes;
-(void)showFoundSpaces;
-(void)runSearch;

@end
