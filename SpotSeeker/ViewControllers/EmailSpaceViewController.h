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

@interface EmailSpaceViewController : UITableViewController <UITextViewDelegate, RESTFinished, ABPeoplePickerNavigationControllerDelegate> {
    
}


@property (nonatomic, retain) Space *space;
@property (nonatomic, retain) OverlayMessage *overlay;
@property (nonatomic, retain) REST *rest;
@property (nonatomic) BOOL is_sending_email;

-(IBAction)sendEmail:(id)selector;
-(IBAction)openContactChooser:(id)selector;
@end
