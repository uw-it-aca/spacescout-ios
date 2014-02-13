//
//  TimeFilterTableViewController.h
//  SpaceScout
//
//  Created by Michael Seibel on 2/6/14.
//
//

#import <UIKit/UIKit.h>

@interface TimeFilterTableViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource>

-(IBAction)resetBtnClick:(id)sender;
-(IBAction)cancelBtnClick:(id)sender;

@property (weak, nonatomic) UIPickerView *time_picker;
@property (nonatomic, strong) NSIndexPath *time_picker_index_path;
@property (assign) NSInteger pickerCellRowHeight;
@property (nonatomic, retain) NSMutableDictionary *filter;

// this button appears only when the date picker is shown (iOS 6.1.x or earlier)
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;


@end
