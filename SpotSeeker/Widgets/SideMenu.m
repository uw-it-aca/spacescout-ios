//
//  SideMenu.m
//  SpaceScout
//
//  Created by Patrick Michaud on 3/2/14.
//
//

#import "SideMenu.h"
#import "UIImage+ImageEffects.h"

@implementation SideMenu
@synthesize navigation_menu_view;

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
    
    // Has the actual menu items
    UIView *menu = [[[NSBundle mainBundle] loadNibNamed:@"NavigationMenu" owner:self options:nil] objectAtIndex:0];
    menu.clipsToBounds = TRUE;
    
    menu.tag = 101;
    
    // Add the drop shadow

    
    [self.navigation_menu_view addSubview:menu];
    
}

-(IBAction)logstuff:(UITapGestureRecognizer *)tapRecognizer {
    UIView *menu_view = [self.navigation_menu_view viewWithTag:101];
    if ([tapRecognizer locationInView:self.navigation_menu_view].x > menu_view.frame.size.width) {
        [self slideHideMenu];
    }
    
}

-(void) addTouchEvents {
    UITapGestureRecognizer *touchOnView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logstuff:)];
    [touchOnView setNumberOfTapsRequired:1];
    [touchOnView setNumberOfTouchesRequired:1];
    [self.navigation_menu_view addGestureRecognizer:touchOnView];
 
    UIView *menu_view = [self.navigation_menu_view viewWithTag:101];
    
    UIButton *fav_button = (UIButton *)[menu_view viewWithTag:301];
    UIButton *logout_button = (UIButton *)[menu_view viewWithTag:302];
    UIButton *campus_chooser = (UIButton *)[menu_view viewWithTag:303];
    UIButton *suggest_space = (UIButton *)[menu_view viewWithTag:304];

   
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

-(void) showMenuForViewController:(UIViewController *)vc {
    self.view_controller = vc;

    [self quickHideMenu];
    vc.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;

    UIImage *image = [self getBackgroundImageForViewController:vc];
    UIImage *blurred_image = [self getBlurredImageFromUIImage:image];
    
    if (!self.navigation_menu_view) {
        [self buildViews];
    }
    
    UIViewController *menu_overlay = [[UIViewController alloc] init];

    menu_overlay.view = self.navigation_menu_view;
    
//    [self.view_controller.navigationController.view addSubview:self.navigation_menu_view];
    
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
    float final_width = frame.size.width * 0.9;
    
    [img_view setImage:blurred_image];
    
    frame.size.width = 0;
    img_view.frame = frame;
 
    menu_view.frame = frame;

    [menu_view setClipsToBounds:TRUE];
    
    backing_view.frame = frame;
    [img_view setClipsToBounds:YES];
    [img_view setContentMode:UIViewContentModeLeft];
    
    CGRect final_frame = frame;

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

    final_frame.size.width = final_width;
    [self addTouchEvents];

    CGRect final_shadow_frame = CGRectMake(self.navigation_menu_view.frame.size.width * 0.9, 0, self.navigation_menu_view.frame.size.width * 0.1, self.navigation_menu_view.frame.size.height);
    
    [UIView animateWithDuration:0.3 delay: 0.0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        img_view.frame = final_frame;
        menu_view.frame = final_frame;
        backing_view.frame = final_frame;
       
        shadow.frame = final_shadow_frame;

    } completion:^(BOOL finished) {
        if (finished) {
        }
    }];

}

-(void)slideHideMenu {
    CGRect final_frame = self.view_controller.view.frame;
    final_frame.size.width = 0;
    UIView *img_view = [self.navigation_menu_view viewWithTag:100];
    UIView *menu_view = [self.navigation_menu_view viewWithTag:101];
    UIView *backing_view = [self.navigation_menu_view viewWithTag:103];
    UIView *shadow_view = [self.navigation_menu_view viewWithTag:104];

    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.navigation_menu_view.frame = final_frame;
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
    [self.view_controller dismissViewControllerAnimated:NO completion:^(void) {
    }];
    [self.view_controller performSegueWithIdentifier:@"open_favorites" sender:self.view_controller];
    [self quickHideMenu];
}

-(void)campusChooserButtonTouchUp: (id)sender {
    [self.view_controller dismissViewControllerAnimated:NO completion:^(void) {
    }];
    [self.view_controller performSegueWithIdentifier:@"choose_campus" sender:self.view_controller];
    [self quickHideMenu];
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

    mailComposer.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
    
    [self.view_controller dismissViewControllerAnimated:NO completion:^(void) {
    }];
    [self.view_controller presentViewController:mailComposer animated:YES completion:^(void) {
        [self quickHideMenu];
    }];
   
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
