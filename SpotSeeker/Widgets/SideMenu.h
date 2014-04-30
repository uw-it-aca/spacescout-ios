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
#import "SideMenuViewController.h"


@interface SideMenu : NSObject <MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate> {
}

@property (nonatomic, retain) UIView *navigation_menu_view;
@property (nonatomic, retain) UIViewController *view_controller;
@property (nonatomic, retain) UIViewController *menu_view_controller;
@property (nonatomic, retain) UIView *view;

+(UIViewController *)rootVCForVC:(UIViewController *)vc;
-(void)showMenu;
-(IBAction)favButtonTouchUp: (id)sender;
-(void)addSwipeToOpenMenuToView: (UIView *)view;
-(void)setOpeningViewController: (UIViewController *)vc;

@end
