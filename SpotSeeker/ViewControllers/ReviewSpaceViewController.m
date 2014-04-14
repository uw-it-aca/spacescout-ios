//
//  ReviewSpaceViewController.m
//  SpaceScout
//
//  Created by pmichaud on 4/1/14.
//
//

#import "ReviewSpaceViewController.h"
const int MAX_REVIEW_LENGTH = 300;
NSString *SELECTED_IMAGE = @"StarRating-big_filled";
NSString *UNSELECTED_IMAGE = @"StarRating-big_blank";

@implementation ReviewSpaceViewController

@synthesize handling_login;
@synthesize space;
@synthesize rating;

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
    else {
        self.title = self.space.name;
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *new_text = [textView.text stringByReplacingCharactersInRange:range withString:text];

    if (new_text.length > MAX_REVIEW_LENGTH) {
        return FALSE;
    }
    
    NSInteger whats_left = MAX_REVIEW_LENGTH - new_text.length;
    UILabel *amount_left = (UILabel *)[self.view viewWithTag:100];
    amount_left.text = [NSString stringWithFormat:@"Chars left: %li", (long)whats_left];
    
    [self checkForValidReview];

    return TRUE;
}

-(IBAction)submitReview:(id)sender {
    self.rest = [[REST alloc] init];
    self.rest.delegate = self;
    
    // Make it so we don't double send - the overlay doesn't cover the send button
    
    UITextView *review = (UITextView *)[self.view viewWithTag:101];
    NSDictionary *data = @{@"rating": [NSNumber numberWithInteger:rating],
                           @"review": [review text]
                           };
    
    NSString *url = [NSString stringWithFormat:@"/api/v1/spot/%@/reviews", self.space.remote_id];
    
    if (!self.overlay) {
        self.overlay = [[OverlayMessage alloc] init];
        [self.overlay addTo:self.view];
    }
    [self.overlay showOverlay:@"Submitting..." animateDisplay:YES afterShowBlock:^(void) {
        [self.rest postURL:url withBody:[data JSONRepresentation]];
    }];

}

-(void)requestFromREST:(ASIHTTPRequest *)request {
    if ([request responseStatusCode] == 200) {
        [self.overlay showOverlay:@"Review submitted.  Pending approval." animateDisplay:NO afterShowBlock:^(void) {
            [self.overlay hideOverlayAfterDelay:4.0 animateHide:NO afterHideBlock:^(void) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
    }
    else {
        [self.overlay showOverlay:@"Error sending review" animateDisplay:NO afterShowBlock:^(void) {}];
    }
}

-(IBAction)selectRating:(id)sender {
    NSInteger tag = [sender tag];
    
    self.rating = tag-200;
    
    for (int i = 201; i <= tag; i++) {
        UIButton *selected = (UIButton *)[self.view viewWithTag:i];
        [selected setImage:[UIImage imageNamed:SELECTED_IMAGE] forState:UIControlStateHighlighted];
        [selected setImage:[UIImage imageNamed:SELECTED_IMAGE] forState:UIControlStateNormal];
        [selected setImage:[UIImage imageNamed:SELECTED_IMAGE] forState:UIControlStateSelected];
    }
    for (NSInteger i = tag + 1; i <= 205; i++) {
        UIButton *selected = (UIButton *)[self.view viewWithTag:i];
        [selected setImage:[UIImage imageNamed:UNSELECTED_IMAGE] forState:UIControlStateHighlighted];
        [selected setImage:[UIImage imageNamed:UNSELECTED_IMAGE] forState:UIControlStateNormal];
        [selected setImage:[UIImage imageNamed:UNSELECTED_IMAGE] forState:UIControlStateSelected];
    }
    [self checkForValidReview];
}

-(void)checkForValidReview {
    UIButton *submit = (UIButton *)[self.view viewWithTag:300];
    if ([self hasValidReview]) {
        submit.enabled = TRUE;
    }
    else {
        submit.enabled = FALSE;
    }
}

-(BOOL)hasValidReview {
    if (!self.rating) {
        return FALSE;
    }
    UITextView *review = (UITextView *)[self.view viewWithTag:101];
    if (!review.text.length) {
        return FALSE;
    }
    return TRUE;
}

-(void)backButtonPressed:(id)sender {
}

-(void)loginCancelled {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loginComplete {
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];
    
    [self.view addGestureRecognizer:tap];
    
    UIButton *submit = (UIButton *)[self.view viewWithTag:300];
    submit.enabled = FALSE;

    UITextView *review = (UITextView *)[self.view viewWithTag:101];
    review.layer.borderColor = [[UIColor blackColor] CGColor];
    review.layer.borderWidth = 0.5;
    self.automaticallyAdjustsScrollViewInsets = NO;   
}

-(void)dismissKeyboard:(id)selector {
    UITextView *review = (UITextView *)[self.view viewWithTag:101];
    if ([review isFirstResponder]) {
        [review resignFirstResponder];
    }
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
