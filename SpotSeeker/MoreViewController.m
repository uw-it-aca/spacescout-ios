//
//  MoreViewController.m
//  SpaceScout
//
//  Created by Michael Seibel on 1/28/14.
//
//

#import "MoreViewController.h"

@interface MoreViewController ()
{
    NSArray *contacts;
}

@end

@implementation MoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.campusPicker.delegate = self;
    self.campusPicker.dataSource = self;

    contacts = [Contact getContacts];

	// Do any additional setup after loading the view.

    // set selected campus
    NSArray *campuses = [Campus getCampuses];
    int selected_index = 0; // Default to the first item in the list.
    Campus *current = [Campus getCurrentCampus];
    
    for (int i = 0; i < [campuses count]; i++) {
        Campus *campus = [campuses objectAtIndex:i];
        if ([campus.search_key isEqualToString:current.search_key]) {
            selected_index = i;
            break;
        }
    }

    [self.campusPicker selectRow:selected_index inComponent:0 animated:false];
    
    UIButton *logout_button = (UIButton *)[self.view viewWithTag:301];
    if ([REST hasPersonalOAuthToken]) {
        logout_button.hidden = FALSE;
    }
    else {
        logout_button.hidden = TRUE;
        UIView *background = [self.view viewWithTag:400];
        UILabel *description = (UILabel *)[self.view viewWithTag:401];
        background.hidden = TRUE;
        description.hidden = TRUE;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[Campus getCampuses] count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray *campuses = [Campus getCampuses];
    Campus *campus = [campuses objectAtIndex:row];
    return campus.name;
}

- (IBAction)btnClickClose:(id)sender {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.35;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromLeft;
    
    // NSLog(@"%s: controller.view.window=%@", _func_, controller.view.window);
    UIView *containerView = self.view.window;
    [containerView.layer addAnimation:transition forKey:nil];

    [self.presentingViewController dismissViewControllerAnimated:NO completion:^(void) {
    }];
}


-(void)logoutButtonTouchUp: (id)sender {
    [REST removePersonalOAuthToken];
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (!self.overlay) {
        self.overlay = [[OverlayMessage alloc] init];
        [self.overlay addTo:self.view];
    }


    [self.overlay showOverlay:@"Logged Out" animateDisplay:YES afterShowBlock:^(void) {
        UIButton *logout_button = (UIButton *)[self.view viewWithTag:301];
        logout_button.hidden = TRUE;

        [self.overlay hideOverlayAfterDelay:1.0 animateHide:YES afterHideBlock:^(void) {
            [self.navigationController popViewControllerAnimated:TRUE];
        }];
    }];

}


-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
    }
    [super viewWillDisappear:animated];
 
    NSInteger row = [self.campusPicker selectedRowInComponent:0];
    Campus *campus = [[Campus getCampuses] objectAtIndex:row];
    Campus *current_campus = [Campus getCurrentCampus];

    if ([current_campus.search_key isEqualToString:campus.search_key]) {
        return;
    }

    [Campus setNextCampus: campus];
}

@end
