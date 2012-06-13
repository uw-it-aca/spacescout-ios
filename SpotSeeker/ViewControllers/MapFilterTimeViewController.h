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
    NSDateComponents *start_time;
    NSDateComponents *end_time;
    NSNumber *current_widget;
}

-(IBAction)timeSelected:(id)sender;
-(IBAction)startTimeBtnClick:(id)sender;
-(IBAction)endTimeBtnClick:(id)sender;
-(IBAction)resetBtnClick:(id)sender;
-(IBAction)doneBtnClick:(id)sender;
-(IBAction)cancelBtnClick:(id)sender;


@property (nonatomic, retain) UIPickerView *time_picker;
@property (nonatomic, retain) NSMutableDictionary *filter;
@property (nonatomic, retain) NSDateComponents *start_time;
@property (nonatomic, retain) NSDateComponents *end_time;
@property (nonatomic, retain) NSNumber *current_widget;

@end
