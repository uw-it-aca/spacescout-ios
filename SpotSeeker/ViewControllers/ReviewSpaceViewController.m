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

#define is3_5InchDevice ([[UIScreen mainScreen] bounds].size.height == 480) ? TRUE : FALSE

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

-(NSInteger)reviewCharCount:(NSString *)review {
    NSMutableCharacterSet *char_set = [[NSMutableCharacterSet alloc] init];
    [char_set formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [char_set formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    
    NSString *stripped = [[review componentsSeparatedByCharactersInSet:char_set] componentsJoinedByString:@""];

    return stripped.length;
}

-(void)updateRemainingCharacterCountByNSString:(NSString *)text {
    NSInteger char_count = [self reviewCharCount:text];
    NSInteger whats_left = MAX_REVIEW_LENGTH - char_count;
    UILabel *amount_left = (UILabel *)[self.view viewWithTag:100];
    if (whats_left == 1) {
        amount_left.text = [NSString stringWithFormat:@"1 character left"];
    }
    else {
        amount_left.text = [NSString stringWithFormat:@"%li characters left", (long)whats_left];
        
    }
    
    if (whats_left < 1) {
        amount_left.textColor = [UIColor redColor];
    }
    else {
        amount_left.textColor = [UIColor darkGrayColor];
    }

}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *new_text = [textView.text stringByReplacingCharactersInRange:range withString:text];

    NSInteger char_count = [self reviewCharCount:new_text];
    if (char_count > MAX_REVIEW_LENGTH) {
        return FALSE;
    }
    
    [self updateRemainingCharacterCountByNSString:new_text];
    
    [self checkForValidReview];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *review_key = [NSString stringWithFormat:@"space_review_%@", self.space.remote_id];
    
    [defaults setObject:new_text forKey:review_key];

    return TRUE;
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    UIScrollView *scroll = (UIScrollView *)[self.view viewWithTag:500];
    scroll.scrollEnabled = TRUE;
    
    if (is3_5InchDevice) {
        scroll.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 180);
    }
    else {
        scroll.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 100);
    }
    CGRect bottom = CGRectMake(0, scroll.frame.size.height + 68, 1, 68);
    [scroll scrollRectToVisible:bottom animated:YES];

    [self hideWatermarkWithAnimation:TRUE];
    [self showDoneBarButton];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    UIScrollView *scroll = (UIScrollView *)[self.view viewWithTag:500];
    
    if (is3_5InchDevice) {
        // SPOT-1794
        scroll.scrollEnabled = TRUE;
        scroll.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    }
    else {
        scroll.scrollEnabled = FALSE;
    }
    
    CGRect top = CGRectMake(0, 0, 1, 1);
    [scroll scrollRectToVisible:top animated:YES];

    UITextView *text_view = (UITextView *)[self.view viewWithTag:101];
    if ([text_view.text isEqualToString:@""]) {
        [self showWatermarkWithAnimation:TRUE];
    }
    
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
    UITextField *review = (UITextField *)[self.view viewWithTag:101];
    [review resignFirstResponder];
    UIView *modal_content = [self.view viewWithTag:701];
    modal_content.layer.cornerRadius = 20;
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

    [self.overlay showActivityIndicator];
    [self.overlay showOverlay:@"Sending..." animateDisplay:YES afterShowBlock:^(void) {
        [self.rest postURL:url withBody:[data JSONRepresentation]];
    }];
}

-(void)requestFromREST:(ASIHTTPRequest *)request {
    [self.overlay hideActivityIndicator];

    if ([request responseStatusCode] == 201) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *rating_key = [NSString stringWithFormat:@"space_rating_%@", self.space.remote_id];
        NSString *review_key = [NSString stringWithFormat:@"space_review_%@", self.space.remote_id];
        [defaults removeObjectForKey:rating_key];
        [defaults removeObjectForKey:review_key];
        
        [self.overlay showOverlay:@"Submitted" animateDisplay:NO afterShowBlock:^(void) {
            [self.overlay hideOverlayAfterDelay:1.0 animateHide:NO afterHideBlock:^(void) {
                NSInteger current_index = [self.navigationController.viewControllers indexOfObject:self];
                if (current_index > 2) {
                    UIViewController *details = [[self.navigationController viewControllers] objectAtIndex:current_index - 2];
                    [self.navigationController popToViewController:details animated:TRUE];
                }
                else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }];
        [self.overlay setImage: [UIImage imageNamed:@"GreenCheckmark"]];
    }
    else {
        [self.overlay showOverlay:@"Error.  Try again" animateDisplay:NO afterShowBlock:^(void) {
            [self.overlay hideOverlayAfterDelay:1.0 animateHide:NO afterHideBlock:^(void) {
            }
             ];
        }];
        NSLog(@"Status: %i, Body: %@", [request responseStatusCode], [request responseString]);
        [self.overlay showOverlay:@"Error" animateDisplay:NO afterShowBlock:^(void) {}];
    }
}

-(IBAction)selectRating:(id)sender {
    NSInteger tag = [sender tag];
    
    self.rating = tag-200;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *rating_key = [NSString stringWithFormat:@"space_rating_%@", self.space.remote_id];
    [defaults setObject:[NSNumber numberWithInteger:self.rating] forKey:rating_key];
    
    [self setRatingDisplay: self.rating];
    
    [self checkForValidReview];
}

-(void)setRatingDisplay:(NSInteger) _rating {
    NSInteger tag = _rating + 200;
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
            rating_desc.text = @"I won’t be back";
            break;
        }
        case 2: {
            rating_desc.text = @"I dislike it";
            break;
        }
        case 3: {
            rating_desc.text = @"It’s ok";
            break;
        }
        case 4: {
            rating_desc.text = @"I like it";
            break;
        }
        case 5: {
            rating_desc.text = @"I love it";
            break;
        }
            
            
    }
    

}

-(void)checkForValidReview {
    UIButton *submit = (UIButton *)[self.view viewWithTag:300];
    if ([self hasValidReview]) {
        submit.enabled = TRUE;
        submit.backgroundColor = [UIColor colorWithRed:81.0/255.0 green:77.0/255.0 blue:163.0/255.0 alpha:1.0];
    }
    else {
        submit.enabled = FALSE;
        submit.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
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
    [self dismissViewControllerAnimated:YES completion:^(void) {}];
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
    
    if ([REST hasPersonalOAuthToken]) {
        [submit_button setTitle:@"Submit" forState:UIControlStateDisabled];
        [submit_button setTitle:@"Submit" forState:UIControlStateSelected];
        [submit_button setTitle:@"Submit" forState:UIControlStateNormal];

    }
    else {
        [submit_button setTitle:@"Log in & Submit" forState:UIControlStateDisabled];
        [submit_button setTitle:@"Log in & Submit" forState:UIControlStateSelected];
        [submit_button setTitle:@"Log in & Submit" forState:UIControlStateNormal];
    }
    
    UIView *modal = [self.view viewWithTag:701];
    modal.layer.cornerRadius = 3.0;
    [self hideDoneBarButton];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *rating_key = [NSString stringWithFormat:@"space_rating_%@", self.space.remote_id];
    NSString *review_key = [NSString stringWithFormat:@"space_review_%@", self.space.remote_id];
    
    if ([defaults valueForKey:rating_key]) {
        self.rating = [[defaults objectForKey:rating_key] integerValue];
        [self setRatingDisplay:self.rating];
    }
    
    if ([defaults valueForKey:review_key]) {
        UITextView *review = (UITextView *)[self.view viewWithTag:101];
        review.text = [defaults valueForKey:review_key];
        if (![review.text isEqualToString:@""]) {
            [self hideWatermarkWithAnimation:FALSE];
            [self updateRemainingCharacterCountByNSString:review.text];
        }
    }
    [self checkForValidReview];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    if (is3_5InchDevice) {
        // SPOT-1794
        UIScrollView *scroll = (UIScrollView *)[self.view viewWithTag:500];
        scroll.scrollEnabled = TRUE;
        scroll.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    }
}

-(void)hideWatermarkWithAnimation:(BOOL)animate {
    UILabel *watermark = (UILabel *)[self.view viewWithTag:111];
    if (animate) {
        [UIView animateWithDuration:0.1 animations:^(void) {
            watermark.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                watermark.hidden = TRUE;
            }
        }];
    }
    else {
        watermark.hidden = TRUE;
    }
}

-(void)showWatermarkWithAnimation:(BOOL)animate {
    // Since this is currently shown/hidden when the textview gets/loses focus,
    // rather than based on text, i'm disabling animation - the textview is already
    // doing a motion animation.
    animate = FALSE;
    
    
    UILabel *watermark = (UILabel *)[self.view viewWithTag:111];
    // Prevents flashing if someone keeps hitting backspace.
    if (!watermark.hidden) {
        return;
    }
    
    if (animate) {
        watermark.alpha = 0.0;
        watermark.hidden = FALSE;
        [UIView animateWithDuration:0.1 animations:^(void) {
            watermark.alpha = 1.0;
        } completion:^(BOOL finished) {
        }];

    }
    else {
        watermark.alpha = 1.0;
        watermark.hidden = FALSE;
    }
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

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
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
