//
//  MoreViewController.h
//  SpaceScout
//
//  Created by Michael Seibel on 1/28/14.
//
//

#import <UIKit/UIKit.h>
#import "Campus.h"
#import "Contact.h"

@interface MoreViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, retain) IBOutlet UIPickerView *campusPicker;

@end
