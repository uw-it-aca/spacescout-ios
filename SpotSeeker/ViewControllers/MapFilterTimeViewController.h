//
//  MapFilterTimeViewController.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapFilterTimeViewController : UIViewController {
    IBOutlet UIDatePicker *date_picker;
    NSMutableDictionary *filter;

}

-(IBAction)timeSelected:(id)sender;

@property (nonatomic, retain) UIDatePicker *date_picker;
@property (nonatomic, retain) NSMutableDictionary *filter;

@end
