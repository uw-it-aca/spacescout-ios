//
//  EmailSpaceViewController.h
//  SpaceScout
//
//  Created by Patrick Michaud on 3/4/14.
//
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Space.h"
#import "OverlayMessage.h"

@interface EmailSpaceViewController : UITableViewController <UITextViewDelegate, UITextFieldDelegate, RESTFinished, ABPeoplePickerNavigationControllerDelegate> {
    
}


@property (nonatomic, retain) Space *space;
@property (nonatomic, retain) OverlayMessage *overlay;
@property (nonatomic, retain) REST *rest;
@property (nonatomic) BOOL is_sending_email;
@property (nonatomic, retain) IBOutlet UILabel *room_label;
@property (nonatomic, retain) IBOutlet UILabel *building_label;
@property (nonatomic, retain) NSMutableDictionary *existing_emails;
@property (nonatomic, retain) NSMutableArray *email_list;
@property (nonatomic) CGFloat to_cell_size;
@property (nonatomic) BOOL has_valid_to_email;

-(IBAction)sendEmail:(id)selector;
-(IBAction)openContactChooser:(id)selector;
@end
