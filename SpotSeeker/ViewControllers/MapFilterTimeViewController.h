//
//  MapFilterTimeViewController.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapFilterTimeViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    IBOutlet UIPickerView *time_picker;
    NSMutableDictionary *filter;

}

-(IBAction)timeSelected:(id)sender;

@property (nonatomic, retain) UIPickerView *time_picker;
@property (nonatomic, retain) NSMutableDictionary *filter;

@end
