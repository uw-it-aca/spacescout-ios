//
//  MapFilterViewController.h
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

#import <UIKit/UIKit.h>
#import "Spot.h"
#import "SBJson.h"
#import "MapFilterDetailsViewController.h"


@interface MapFilterViewController : UIViewController <SearchFinished> {
    Spot *spot;
    IBOutlet UIScrollView *scroll_view;
    IBOutlet UIView *filter_view;
       
    IBOutlet UITableView *filter_table;
    
    NSMutableArray *data_sections;
    NSMutableDictionary *current_section;
    
}

- (IBAction) btnClickSearch:(id)sender;
- (IBAction) btnClickCancel:(id)sender;
- (IBAction) btnClickChangeFilter:(id)sender;

@property (nonatomic, retain) UIScrollView *scroll_view;
@property (nonatomic, retain) UIView *filter_view;
@property (nonatomic, retain) Spot *spot;
@property (nonatomic, retain) UITableView *filter_table;
@property (nonatomic, retain) NSMutableArray *data_sections;
@property (nonatomic, retain) NSMutableDictionary *current_section;

@end
