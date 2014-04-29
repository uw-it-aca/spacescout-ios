//
//  SideMenu.m
//  SpaceScout
//
//  Created by Patrick Michaud on 3/2/14.
//
//

#import "SideMenu.h"
#import "UIImage+ImageEffects.h"
#import "FavoriteSpacesViewController.h"
#import "MoreViewController.h"
#import "MainListViewController.h"

@implementation SideMenu
@synthesize navigation_menu_view;
@synthesize menu_view_controller;
@synthesize view;
const float SWIPE_CLOSE_THRESHOLD = 0.3;
const float SIDE_MENU_START_SWIPE = 50.0;

-(void)setOpeningViewController:(UIViewController *)vc {
    self.view_controller = vc;
}

-(void)addSwipeToOpenMenuToView:(UIView *)_view {
    self.view = _view;
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [view addGestureRecognizer:swipe];
}

-(void)handleSwipe:(UISwipeGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.view];
    if (location.x < SIDE_MENU_START_SWIPE) {
        [self openNavigationMenu:nil];
    }
}

-(IBAction)openNavigationMenu:(id)sender {
    [self showMenu];
}


-(UIImage *)getBackgroundImageForViewController:(UIViewController *)vc {
    UIImage *image;
    
    UIGraphicsBeginImageContextWithOptions(vc.view.frame.size, true, 0.0);
//    UIGraphicsBeginImageContext(vc.view.frame.size);
    [vc.navigationController.view drawViewHierarchyInRect:vc.view.frame afterScreenUpdates:YES];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

-(UIImage *)getBlurredImageFromUIImage:(UIImage *)image {
    // No longer blurring the background image!  Keeping this in case we change our minds again
    return image;
//    UIImage *blurredSnapshotImage = [image applyLightEffect];
//    return blurredSnapshotImage;
}

-(void) buildViews {
    self.navigation_menu_view = [[UIView alloc] init];
    self.navigation_menu_view.hidden = TRUE;
    
    // Has the full screen capture
    UIImageView *background_img = [[UIImageView alloc] init];
    background_img.backgroundColor = [UIColor redColor];
    
    background_img.tag= 102;
    [self.navigation_menu_view addSubview:background_img];
    
    
    // Background for the blurred/cropped screen
    UIView *backing = [[UIView alloc] init];
    backing.backgroundColor = [UIColor redColor];
    
    backing.tag = 103;
    backing.backgroundColor = [UIColor whiteColor];
    [self.navigation_menu_view addSubview:backing];

    // The dropshadow image
    UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_shadow.png"]];
    shadow.tag = 104;
    shadow.frame = CGRectMake(0, 0, self.navigation_menu_view.frame.size.width * 0.1, self.navigation_menu_view.frame.size.height);
    
    [self.navigation_menu_view addSubview:shadow];

    
    // Has the blurred/cropped screed
    UIImageView *base_img_view = [[UIImageView alloc] init];
    
    [self.navigation_menu_view addSubview:base_img_view];
    base_img_view.tag = 100;
    base_img_view.alpha = 0.8;
    

    UIView *menu;
    // Need to do the 3.5 vs 4 inch check.  Constraints-based positioning wasn't working in the xib
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480) {
            menu = [[[NSBundle mainBundle] loadNibNamed:@"NavigationMenu" owner:self options:nil] objectAtIndex:1];
            
        }
        else {
            // hopefully this will work when another size comes along...
            menu = [[[NSBundle mainBundle] loadNibNamed:@"NavigationMenu" owner:self options:nil] objectAtIndex:0];
        }
    }
    menu.clipsToBounds = TRUE;
    
    menu.tag = 101;
    
    
    [self.navigation_menu_view addSubview:menu];
    
}

-(IBAction)closeOnOutsideTap:(UITapGestureRecognizer *)tapRecognizer {
    UIView *menu_view = [self.navigation_menu_view viewWithTag:101];
    if ([tapRecognizer locationInView:self.navigation_menu_view].x > menu_view.frame.size.width) {
        [self slideHideMenu];
    }
    
}

-(IBAction)moveMenuWithFinger:(UIPanGestureRecognizer *)gesture {
    static CGPoint first_touch;
    CGPoint current_position;
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        first_touch = [gesture translationInView:gesture.view.superview];
        
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        current_position = [gesture translationInView:gesture.view.superview];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        current_position = [gesture translationInView:gesture.view.superview];
        float dx = current_position.x - first_touch.x;

        if (-1 * dx > self.view_controller.view.frame.size.width * SWIPE_CLOSE_THRESHOLD) {
            [self slideHideMenu];
        }
        else {
            [self slideOpenMenu];
        }
        return;
    }
    else {
        return;
    }
    
    // Don't move the menu too far right!
    float dx = current_position.x - first_touch.x;
    if (dx > 0) {
        dx = 0;
    }
    
    CGRect frame = self.view_controller.view.frame;
    float final_width = frame.size.width * 0.9;
    CGRect shadow_frame = CGRectMake(self.navigation_menu_view.frame.size.width * 0.9, 0, self.navigation_menu_view.frame.size.width * 0.1, self.navigation_menu_view.frame.size.height);

    float percent_at_clear = 0.7;
    float position_at_clear = final_width * percent_at_clear;
    float percent_alpha = dx / final_width * percent_at_clear;
    
    percent_alpha = (final_width + dx - position_at_clear) / (final_width * (1 - percent_at_clear));
    
    if (percent_alpha < 0) {
        percent_alpha = 0;
    }
    frame.size.width = final_width + dx;
    shadow_frame.origin.x = shadow_frame.origin.x + dx;
    
    UIImageView *img_view = (UIImageView *)[self.navigation_menu_view viewWithTag:100];
    UIView *backing_view = [self.navigation_menu_view viewWithTag:103];
    UIView *menu_view = [self.navigation_menu_view viewWithTag:101];
    UIImageView *shadow = (UIImageView *)[self.navigation_menu_view viewWithTag:104];

    shadow.alpha = percent_alpha;
    img_view.frame = frame;
    menu_view.frame = frame;
    backing_view.frame = frame;
    shadow.frame = shadow_frame;

}


-(void) addTouchEvents {
    UITapGestureRecognizer *touchOnView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeOnOutsideTap:)];
    [touchOnView setNumberOfTapsRequired:1];
    [touchOnView setNumberOfTouchesRequired:1];
    [self.navigation_menu_view addGestureRecognizer:touchOnView];

    UIPanGestureRecognizer *panning = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveMenuWithFinger:)];
    panning.delegate = self;
    [self.navigation_menu_view addGestureRecognizer:panning];
    
    UIView *menu_view = [self.navigation_menu_view viewWithTag:101];
    
    UIButton *fav_button = (UIButton *)[menu_view viewWithTag:301];
    UIButton *logout_button = (UIButton *)[menu_view viewWithTag:302];
    UIButton *campus_chooser = (UIButton *)[menu_view viewWithTag:303];
    UIButton *suggest_space = (UIButton *)[menu_view viewWithTag:304];
    UIButton *icon_button = (UIButton *)[menu_view viewWithTag:1300];

    [icon_button removeTarget:nil
                      action:NULL
            forControlEvents:UIControlEventAllEvents];
    
    [icon_button addTarget:self action:@selector(homeButtonTouchUp:) forControlEvents: UIControlEventTouchUpInside];
    
    [fav_button removeTarget:nil
                      action:NULL
            forControlEvents:UIControlEventAllEvents];
    
    [fav_button addTarget:self action:@selector(favButtonTouchUp:) forControlEvents: UIControlEventTouchUpInside];
    

    [logout_button removeTarget:nil
                      action:NULL
            forControlEvents:UIControlEventAllEvents];
    
    [logout_button addTarget:self action:@selector(logoutButtonTouchUp:) forControlEvents: UIControlEventTouchUpInside];

    [campus_chooser removeTarget:nil
                         action:NULL
               forControlEvents:UIControlEventAllEvents];
    
    [campus_chooser addTarget:self action:@selector(campusChooserButtonTouchUp:) forControlEvents: UIControlEventTouchUpInside];

    [campus_chooser removeTarget:nil
                          action:NULL
                forControlEvents:UIControlEventAllEvents];
    
    [campus_chooser addTarget:self action:@selector(campusChooserButtonTouchUp:) forControlEvents: UIControlEventTouchUpInside];

    
    if (![MFMailComposeViewController canSendMail]) {
        suggest_space.enabled = FALSE;
    }
    else {
        [suggest_space removeTarget:nil
                             action:NULL
                   forControlEvents:UIControlEventAllEvents];
        
        [suggest_space addTarget:self action:@selector(openSuggestASpace:) forControlEvents: UIControlEventTouchUpInside];
    }
}

-(void) showMenu {
    UIViewController *vc = self.view_controller;
    [self quickHideMenu];
    vc.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;

    UIImage *image = [self getBackgroundImageForViewController:vc];
    UIImage *blurred_image = [self getBlurredImageFromUIImage:image];
    
    [self buildViews];
    
    UIViewController *menu_overlay = [[SideMenuViewController alloc] init];
    self.menu_view_controller = menu_overlay;

    menu_overlay.view = self.navigation_menu_view;
    
    [self.view_controller presentViewController:menu_overlay animated:NO completion:^(void) {}];

    self.navigation_menu_view.hidden = FALSE;

    UIImageView *img_view = (UIImageView *)[self.navigation_menu_view viewWithTag:100];
    UIView *backing_view = [self.navigation_menu_view viewWithTag:103];
    UIView *menu_view = [self.navigation_menu_view viewWithTag:101];

    UIImageView *background_img_view = (UIImageView *)[self.navigation_menu_view viewWithTag:102];
    UIImageView *shadow = (UIImageView *)[self.navigation_menu_view viewWithTag:104];

    
    background_img_view.frame = self.view_controller.view.frame;
    background_img_view.image = image;
    
    CGRect frame = self.view_controller.view.frame;
    
    [img_view setImage:blurred_image];
    
    frame.size.width = 0;
    img_view.frame = frame;
    shadow.frame = frame;
    menu_view.frame = frame;

    [menu_view setClipsToBounds:TRUE];
    
    backing_view.frame = frame;
    [img_view setClipsToBounds:YES];
    [img_view setContentMode:UIViewContentModeLeft];

    UILabel *favs_count_label = (UILabel *)[menu_view viewWithTag:310];

    int fav_count = [Favorites getFavoritesCount];
    favs_count_label.text = [NSString stringWithFormat:@"%i", fav_count];

    if (fav_count < 1) {
        favs_count_label.hidden = TRUE;
    }
    else {
        favs_count_label.hidden = FALSE;
    }
    
    self.navigation_menu_view.hidden = FALSE;

    [self addTouchEvents];


    [self slideOpenMenu];
}

-(void)slideOpenMenu {
    UIImageView *img_view = (UIImageView *)[self.navigation_menu_view viewWithTag:100];
    UIView *backing_view = [self.navigation_menu_view viewWithTag:103];
    UIView *menu_view = [self.navigation_menu_view viewWithTag:101];
    
    UIImageView *shadow = (UIImageView *)[self.navigation_menu_view viewWithTag:104];
    // This is needed because swipe to close hides the shadow as step 1

    CGRect frame = self.view_controller.view.frame;
    float final_width = frame.size.width * 0.9;
    CGRect final_frame = frame;
    final_frame.size.width = final_width;

    
    CGRect final_shadow_frame = CGRectMake(self.navigation_menu_view.frame.size.width * 0.9, 0, self.navigation_menu_view.frame.size.width * 0.1, self.navigation_menu_view.frame.size.height);
    
    [UIView animateWithDuration:0.3 delay: 0.0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        img_view.frame = final_frame;
        menu_view.frame = final_frame;
        backing_view.frame = final_frame;
        
        shadow.frame = final_shadow_frame;
        shadow.alpha = 1.0;

    } completion:^(BOOL finished) {
        if (finished) {
        }
    }];
    
}

-(void)slideHideMenu {
    CGRect final_frame = self.view_controller.view.frame;
    float full_width = final_frame.size.width * 0.9;

    final_frame.size.width = 0;
    UIView *img_view = [self.navigation_menu_view viewWithTag:100];
    UIView *menu_view = [self.navigation_menu_view viewWithTag:101];
    UIView *backing_view = [self.navigation_menu_view viewWithTag:103];
    UIView *shadow_view = [self.navigation_menu_view viewWithTag:104];

    CGRect current_frame = menu_view.frame;
    float current_width = current_frame.size.width;

    float percent_open = current_width / full_width;
    
    float full_duration = 0.3;
    
    float actual_duration = full_duration * percent_open;
    
    [UIView animateWithDuration:actual_duration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        img_view.frame = final_frame;
        menu_view.frame = final_frame;
        backing_view.frame = final_frame;
        shadow_view.frame = final_frame;
    } completion:^(BOOL finished){
        [self.view_controller dismissViewControllerAnimated:NO completion:^(void) {
        }];
        [self quickHideMenu];
    }];
    
}

-(void)quickHideMenu {
    self.navigation_menu_view.hidden = TRUE;
    // Return to full screen flip
    self.view_controller.navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
}

-(void)favButtonTouchUp: (id)sender {
    if ([self.view_controller isKindOfClass:[FavoriteSpacesViewController class]]) {
        [self slideHideMenu];
        return;
    }
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    FavoriteSpacesViewController *favorites = (FavoriteSpacesViewController *)[sb instantiateViewControllerWithIdentifier:@"favorites-vc"];

    self.view_controller.navigationController.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:favorites];
}

-(void)presentViewController:(UIViewController *)vc {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.35;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    
    // NSLog(@"%s: self.view.window=%@", _func_, self.view.window);
    UIView *containerView = self.view_controller.view.window;
    [containerView.layer addAnimation:transition forKey:nil];

    UINavigationController *nav_controller = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.menu_view_controller presentViewController:nav_controller animated:NO completion:^(void) {}];
}

-(void)campusChooserButtonTouchUp: (id)sender {
    if ([self.view_controller isKindOfClass:[MoreViewController class]]) {
        [self slideHideMenu];
        return;
    }

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    MoreViewController *settings = (MoreViewController *)[sb instantiateViewControllerWithIdentifier:@"settings-vc"];
    
    self.view_controller.navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:settings];
}

-(void)homeButtonTouchUp:(id)sender {
    if ([self.view_controller isKindOfClass:[MapViewController class]]) {
        [self slideHideMenu];
        return;
    }
    if ([self.view_controller isKindOfClass:[MainListViewController class]]) {
        [self slideHideMenu];
        return;
    }

    
    UIViewController *root;
    
    UIViewController *next;
    UIViewController *current = self.view_controller;
    
    while (nil != current) {
        root = current;
        next = current.parentViewController;
        if (nil == next) {
            next = current.presentingViewController;
        }
        current = next;
        
        // XXX - this isn't really a great approach, but without this check, if someone's
        // started from the list view, closing the menu will take you to the map view, with
        // the segment controller in the wrong state.
        UISegmentedControl *segments = (UISegmentedControl *)[root.view viewWithTag:5000];
        if (nil != segments) {
            current = nil;
        }
    }
    
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.35;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    
    UIView *containerView = self.view.window;
    [containerView.layer addAnimation:transition forKey:nil];

    [root dismissViewControllerAnimated:YES completion:^(void) {}];
}

-(void)logoutButtonTouchUp: (id)sender {
    [REST removePersonalOAuthToken];
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self slideHideMenu];
}

-(void)openSuggestASpace:(id)sender {

    NSArray *contacts = [Contact getContacts];
    
    Contact *contact = [contacts objectAtIndex:0];
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc]init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setToRecipients:contact.email_to];
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendFormat:@"[%s] %s",
     [[contact.type capitalizedString] UTF8String],
     [contact.title UTF8String]];
    [mailComposer setSubject:string];
    [string setString:@""];
    if ([contact.email_prefix length]) {
        [string appendFormat:@"(%s)\n\n", [contact.email_prefix UTF8String]];
    }
    
    for (id field in contact.fields) {
        NSString *name = [field objectForKey:@"name"];
        if ([name length]) {
            if ([[field objectForKey:@"required"] boolValue]) {
                [string appendFormat:@"%s: \n", [name UTF8String]];
            } else {
                [string appendFormat:@"%s (optional): \n", [name UTF8String]];
            }
        }
    }
    
    if ([contact.email_postfix length]) {
        [string appendFormat:@"\n(%s)", [contact.email_postfix UTF8String]];
    }
    
    [mailComposer setMessageBody:string isHTML:NO];

    self.view_controller.navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
 
    [self.menu_view_controller presentViewController:mailComposer animated:YES completion:^(void) {}];
}

#pragma mark - mail compose delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result) {
        NSLog(@"Result : %d",result);
    }
    if (error) {
        NSLog(@"Error : %@",error);
    }
    
    [self.view_controller dismissViewControllerAnimated:YES completion:^(void) {}];
}


@end
