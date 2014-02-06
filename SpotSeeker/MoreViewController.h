//
//  MoreViewController.h
//  SpaceScout
//
//  Created by Michael Seibel on 1/28/14.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Campus.h"
#import "Contact.h"

@interface MoreViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contactView;
@property (nonatomic, retain) IBOutlet UIPickerView *campusPicker;

@end
