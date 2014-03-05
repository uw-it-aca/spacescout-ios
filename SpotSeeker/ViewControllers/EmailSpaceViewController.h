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

@interface EmailSpaceViewController : UIViewController <UITextViewDelegate, RESTFinished, ABPeoplePickerNavigationControllerDelegate> {
    
}


@property (nonatomic, retain) Space *space;
@property (nonatomic, retain) REST *rest;
-(IBAction)sendEmail:(id)selector;
-(IBAction)openContactChooser:(id)selector;
@end
