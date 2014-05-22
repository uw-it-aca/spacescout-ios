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
#import "REST.h"
#import "OverlayMessage.h"
#import "SideMenu.h"
#import "OAuthLoginViewController.h"

@interface MoreViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, OAuthLogin>

@property (nonatomic, retain) IBOutlet UIPickerView *campusPicker;
@property (nonatomic, retain) OverlayMessage *overlay;
@property (nonatomic, retain) SideMenu *side_menu;
@property (nonatomic, retain) OAuthLoginViewController *auth_vc;

-(IBAction)logoutButtonTouchUp:(id)sender;
-(IBAction) btnClickClose:(id)sender;


@end
