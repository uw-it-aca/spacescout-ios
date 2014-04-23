//
//  SideMenu.h
//  SpaceScout
//
//  Created by Patrick Michaud on 3/2/14.
//
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "Favorites.h"
#import "Contact.h"
#import <MessageUI/MessageUI.h>


@interface SideMenu : NSObject <MFMailComposeViewControllerDelegate> {
}

@property (nonatomic, retain) UIView *navigation_menu_view;
@property (nonatomic, retain) UIViewController *view_controller;
@property (nonatomic, retain) UIViewController *menu_view_controller;

-(void)showMenuForViewController:(UIViewController *)vc;
-(IBAction)favButtonTouchUp: (id)sender;

@end
