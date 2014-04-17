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

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *new_text = [textView.text stringByReplacingCharactersInRange:range withString:text];

    if (new_text.length > MAX_REVIEW_LENGTH) {
        return FALSE;
    }
    
    NSInteger whats_left = MAX_REVIEW_LENGTH - new_text.length;
    UILabel *amount_left = (UILabel *)[self.view viewWithTag:100];
    if (whats_left == 1) {
        amount_left.text = [NSString stringWithFormat:@"1 character left"];
    }
    else {
        amount_left.text = [NSString stringWithFormat:@"%li characters left", (long)whats_left];

    }
    [self checkForValidReview];

    return TRUE;
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    UIScrollView *scroll = (UIScrollView *)[self.view viewWithTag:500];
    scroll.scrollEnabled = TRUE;
    scroll.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 100);
    CGRect bottom = CGRectMake(0, scroll.frame.size.height + 68, 1, 68);
    [scroll scrollRectToVisible:bottom animated:YES];

    [self showDoneBarButton];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    UIScrollView *scroll = (UIScrollView *)[self.view viewWithTag:500];
    CGRect top = CGRectMake(0, 0, 1, 1);
    [scroll scrollRectToVisible:top animated:YES];
    scroll.scrollEnabled = FALSE;

    [self hideDoneBarButton];
}

-(void)hideDoneBarButton {
    self.navigationItem.rightBarButtonItem.title = @"";
    self.navigationItem.rightBarButtonItem.enabled = FALSE;
}

-(void)showDoneBarButton {
    self.navigationItem.rightBarButtonItem.title = @"Done";
    self.navigationItem.rightBarButtonItem.enabled = TRUE;
}

-(IBAction)finishEditing:(id)selector {
    UITextView *review = (UITextView *)[self.view viewWithTag:101];
    [review resignFirstResponder];
}

-(IBAction)showReviewGuidelines:(id)selector {
    UIView *modal = [self.view viewWithTag:700];
    modal.hidden = FALSE;
}

-(IBAction)hideReviewGuidelines:(id)selector {
    UIView *modal = [self.view viewWithTag:700];
    modal.hidden = TRUE;
}


-(IBAction)submitReview:(id)sender {
    if (![REST hasPersonalOAuthToken]) {
        self.handling_login = TRUE;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
        
        OAuthLoginViewController *auth_vc = [storyboard instantiateViewControllerWithIdentifier:@"OAuth_Login"];
        auth_vc.delegate = self;
        
        //       [self.navigationController presentViewController:auth_vc animated:YES completion:^(void){}];
        [self presentViewController:auth_vc animated:YES completion:^(void) {}];
        return;
    }

    
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
    if ([request responseStatusCode] == 201) {
        [self.overlay showOverlay:@"Review submitted.  Pending approval." animateDisplay:NO afterShowBlock:^(void) {
            [self.overlay hideOverlayAfterDelay:4.0 animateHide:NO afterHideBlock:^(void) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
    }
    else {
        NSLog(@"Status: %i, Body: %@", [request responseStatusCode], [request responseString]);
        [self.overlay showOverlay:@"Error" animateDisplay:NO afterShowBlock:^(void) {}];
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
    
    UILabel *rating_desc = (UILabel *)[self.view viewWithTag:220];
    switch (self.rating) {
        case 1: {
            rating_desc.text = @"You rated: Terrible";
            break;
        }
        case 2: {
            rating_desc.text = @"You rated: Poor";
            break;
        }
        case 3: {
            rating_desc.text = @"You rated: Average";
            break;
        }
        case 4: {
            rating_desc.text = @"You rated: Good";
            break;
        }
        case 5: {
            rating_desc.text = @"You rated: Excellent";
            break;
        }

            
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
    [self submitReview:nil];
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

    UILabel *space_label = (UILabel *)[self.view viewWithTag:600];
    space_label.text = self.space.name;

    UIButton *submit_button = (UIButton *)[self.view viewWithTag:300];
    submit_button.layer.cornerRadius = 3.0;
    
    UIView *modal = [self.view viewWithTag:701];
    modal.layer.cornerRadius = 3.0;
    [self hideDoneBarButton];
    
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
