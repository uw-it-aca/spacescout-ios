//
//  MapFilterPickerViewController.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapFilterPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UIPickerView *filter_picker;
    
    NSMutableDictionary *filter;
    
}

@property (nonatomic, retain) UIPickerView *filter_picker;
@property (nonatomic, retain) NSMutableDictionary *filter;


@end
