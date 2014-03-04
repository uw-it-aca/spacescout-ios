//
//  SideMenu.m
//  SpaceScout
//
//  Created by Patrick Michaud on 3/2/14.
//
//

#import "SideMenu.h"

@implementation SideMenu
@synthesize navigation_menu_view;

-(UIImage *)getBackgroundImageForViewController:(UIViewController *)vc {
    UIImage *image;
    
    UIGraphicsBeginImageContext(vc.view.frame.size);
    [vc.navigationController.view drawViewHierarchyInRect:vc.view.frame afterScreenUpdates:YES];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

-(UIImage *)getBlurredImageFromUIImage:(UIImage *)image {
    // Taken from http://stackoverflow.com/questions/17041669/creating-a-blurring-overlay-view
    
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *blurred_image = [UIImage imageWithCGImage:cgImage];//create a UIImage for this function to "return" so that ARC can manage the memory of the blur... ARC can't manage CGImageRefs so we need to release it before this function "returns" and ends.
    CGImageRelease(cgImage);//release CGImageRef because ARC doesn't manage this on its own.

    return blurred_image;
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
    
    
    // Has the blurred/cropped screed
    UIImageView *base_img_view = [[UIImageView alloc] init];
    
    [self.navigation_menu_view addSubview:base_img_view];
    base_img_view.tag = 100;
    base_img_view.alpha = 0.6;
    
    // Has the actual menu items
    UIView *menu = [[[NSBundle mainBundle] loadNibNamed:@"NavigationMenu" owner:self options:nil] objectAtIndex:0];
    menu.clipsToBounds = TRUE;
    
    menu.tag = 101;
    
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

   
    [fav_button removeTarget:nil
                      action:NULL
            forControlEvents:UIControlEventAllEvents];
    
    [fav_button addTarget:self action:@selector(favButtonTouchUp:) forControlEvents: UIControlEventTouchUpInside];
    

    [logout_button removeTarget:nil
                      action:NULL
            forControlEvents:UIControlEventAllEvents];
    
    [logout_button addTarget:self action:@selector(logoutButtonTouchUp:) forControlEvents: UIControlEventTouchUpInside];
}

-(void) showMenuForViewController:(UIViewController *)vc {
    self.view_controller = vc;
    [self quickHideMenu];

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

    UIButton *favs_button = (UIButton *)[menu_view viewWithTag:301];
    UIButton *logout_button = (UIButton *)[menu_view viewWithTag:302];

    int fav_count = [Favorites getFavoritesCount];
    NSString *fav_label = [NSString stringWithFormat:@"Favorites (%i)", fav_count];
    [favs_button setTitle:fav_label forState:UIControlStateNormal];
    if ([REST hasPersonalOAuthToken]) {
        logout_button.hidden = FALSE;
    }
    else {
        logout_button.hidden = TRUE;
    }
    
    self.navigation_menu_view.hidden = FALSE;

    final_frame.size.width = final_width;
    [self addTouchEvents];
    
    [UIView animateWithDuration:1.2 delay: 0.0 options: UIViewAnimationOptionCurveEaseOut animations:^{
        img_view.frame = final_frame;
        menu_view.frame = final_frame;
        backing_view.frame = final_frame;
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
    
    [UIView animateWithDuration:1.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.navigation_menu_view.frame = final_frame;
        img_view.frame = final_frame;
        menu_view.frame = final_frame;
        backing_view.frame = final_frame;
    } completion:^(BOOL finished){
        if (finished) {
            [self.view_controller dismissViewControllerAnimated:NO completion:^(void) {
            }];
            [self quickHideMenu];
        }
    }];
    
}

-(void)quickHideMenu {
    self.navigation_menu_view.hidden = TRUE;

}

-(void)favButtonTouchUp: (id)sender {
    [self.view_controller dismissViewControllerAnimated:NO completion:^(void) {
    }];
    [self.view_controller performSegueWithIdentifier:@"open_favorites" sender:self.view_controller];
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

@end
