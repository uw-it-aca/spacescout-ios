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

@interface MapFilterViewController : UIViewController <SearchFinished> {
    Spot *spot;
    UIView *current_filter;
    IBOutlet UIScrollView *scroll_view;
    IBOutlet UIView *filter_view;
    
    IBOutlet UIView *basic_filter;
    IBOutlet UIView *access_filter;
    IBOutlet UIView *extras_filter;
    
    IBOutlet UISegmentedControl *filter_control;
   
}

- (IBAction) btnClickSearch:(id)sender;
- (IBAction) btnClickCancel:(id)sender;
- (IBAction) btnClickChangeFilter:(id)sender;

@property (nonatomic, retain) UIScrollView *scroll_view;
@property (nonatomic, retain) UIView *filter_view;
@property (nonatomic, retain) Spot *spot;
@property (nonatomic, retain) UIView *basic_filter;
@property (nonatomic, retain) UIView *access_filter;
@property (nonatomic, retain) UIView *extras_filter;
@property (nonatomic, retain) UIView *current_filter;
@property (nonatomic, retain) UISegmentedControl *filter_control;

@end
