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

NSString *log_in = @"Log in";
NSString *log_out = @"Log out";

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
    
    self.side_menu = [[SideMenu alloc] init];
    [self.side_menu setOpeningViewController:self];
    [self.side_menu addSwipeToOpenMenuToView:self.view];

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
        [logout_button setTitle: log_out forState:UIControlStateNormal];
    }
    else {
        [logout_button setTitle: log_in forState:UIControlStateNormal];
    }
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(btnClickClose:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipe];
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
    [self.side_menu showMenu];
}


-(void)logoutButtonTouchUp: (id)sender {

   
    if ([REST hasPersonalOAuthToken]) {
        [REST removePersonalOAuthToken];
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies]) {
            [storage deleteCookie:cookie];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        [Favorites clearLocalCacheFavorites];
        
        if (!self.overlay) {
            self.overlay = [[OverlayMessage alloc] init];
            [self.overlay addTo:self.view];
        }


        [self.overlay showOverlay:@"Logged Out" animateDisplay:YES afterShowBlock:^(void) {
            [self.overlay hideOverlayAfterDelay:1.0 animateHide:YES afterHideBlock:^(void) {
            }];
        }];
    }
    else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
        OAuthLoginViewController *auth_vc = [storyboard instantiateViewControllerWithIdentifier:@"OAuth_Login"];
        auth_vc.delegate = self;
        
        [self presentViewController:auth_vc animated:YES completion:^(void) {}];

    }
        
    UIButton *logout_button = (UIButton *)[self.view viewWithTag:301];

    if ([REST hasPersonalOAuthToken]) {
        [logout_button setTitle: log_out forState:UIControlStateNormal];
    }
    else {
        [logout_button setTitle: log_in forState:UIControlStateNormal];
    }
    
}

-(void)loginCancelled {
}

-(void)loginComplete {
    UIButton *logout_button = (UIButton *)[self.view viewWithTag:301];
    [logout_button setTitle: log_out forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:^(void){}];
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

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


@end
