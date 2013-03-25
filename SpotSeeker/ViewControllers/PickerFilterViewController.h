//
//  PickerFilterViewController.h
//  SpaceScout
//
//  Created by Patrick Michaud on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface PickerFilterViewController : GAITrackedViewController <UITableViewDataSource,UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>


@property (retain, nonatomic) NSMutableDictionary *filter;
@property (retain, nonatomic) IBOutlet UITableView *table;
@property (retain, nonatomic) IBOutlet UIPickerView *picker;

@end
