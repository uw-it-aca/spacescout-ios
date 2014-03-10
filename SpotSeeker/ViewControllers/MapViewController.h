//
//  MapViewController.h
//  SpotSeeker
//
//  Copyright 2012 UW Information Technology, University of Washington
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <MapKit/MapKit.h>
#import "SBJson.h"
#import "Campus.h"
#import "ViewController.h"
#import "Space.h"
#import "SpaceAnnotation.h"
#import "SpaceDetailsViewController.h"
#import "MapFilterViewController.h"
#import "AnnotationCluster.h"
#import "ListViewController.h"
#import "SearchableSpaceListViewController.h"
#import "AppDelegate.h"
//#import "SpotClusterViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "SideMenu.h"

@interface MapViewController : SearchableSpaceListViewController <MKMapViewDelegate, UIAlertViewDelegate> {
    NSArray *current_clusters;
    NSNumber *from_list;
    MKCoordinateRegion map_region;
    NSArray *cluster_spots_to_display;
    NSMutableDictionary *current_annotations;
    BOOL has_centered_on_location;
    BOOL showing_tip_view;
    BOOL loading;
    NSArray *selected_cluster;
}

@property (nonatomic, retain) NSArray *current_clusters;
@property (nonatomic, retain) NSNumber *from_list;
@property (nonatomic) MKCoordinateRegion map_region;
@property (nonatomic, retain) NSArray *cluster_spots_to_display;
@property (nonatomic, retain) NSMutableDictionary *current_annotations;
@property (nonatomic, retain) NSArray *selected_cluster;
@property (nonatomic, retain) UIAlertView *alert;
@property (nonatomic) Campus *original_campus;

- (IBAction) btnClickRecenter:(id)sender;
//- (IBAction) btnClickCampusSelected:(id)sender;


@end
