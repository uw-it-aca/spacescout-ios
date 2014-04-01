//
//  ReviewSpaceViewController.m
//  SpaceScout
//
//  Created by pmichaud on 4/1/14.
//
//

#import "ReviewSpaceViewController.h"

@interface ReviewSpaceViewController ()

@end

@implementation ReviewSpaceViewController

@synthesize handling_login;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.handling_login) {
        return;
    }
    if (![REST hasPersonalOAuthToken]) {
        self.handling_login = TRUE;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
        
        OAuthLoginViewController *auth_vc = [storyboard instantiateViewControllerWithIdentifier:@"OAuth_Login"];
        auth_vc.delegate = self;
        
        //       [self.navigationController presentViewController:auth_vc animated:YES completion:^(void){}];
        [self presentViewController:auth_vc animated:YES completion:^(void) {}];
    }
}

-(void)backButtonPressed:(id)sender {
}

-(void)loginCancelled {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loginComplete {
    NSLog(@"Complete");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
