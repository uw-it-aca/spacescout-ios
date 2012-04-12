//
//  SpotDetailsViewControllerViewController.h
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

#import "ViewController.h"
#import "Spot.h"

@interface SpotDetailsViewControllerViewController : ViewController {
    Spot *spot;
    NSMutableDictionary *favorite_spots;
    IBOutlet UILabel *capacity_label;
    IBOutlet UIButton *favorite_button;
}

- (IBAction) btnClickFavorite:(id)sender;

@property (nonatomic, retain) Spot *spot;
@property (nonatomic, retain) IBOutlet UILabel *capacity_label;
@property (nonatomic, retain) IBOutlet UIButton *favorite_button;
@property (nonatomic, retain) NSMutableDictionary *favorite_spots;

@end
