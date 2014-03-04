//
//  EmailSpaceViewController.m
//  SpaceScout
//
//  Created by Patrick Michaud on 3/4/14.
//
//

#import "EmailSpaceViewController.h"

@implementation EmailSpaceViewController

@synthesize space;

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
    UITextView *email_field = (UITextView *)[self.view viewWithTag:100];
    email_field.delegate = self;
    
    UITextView *content = (UITextView *)[self.view viewWithTag:101];
    [content setText:@" "];
    [content setText:@""];

    content.layer.borderColor = [[UIColor blackColor] CGColor];
    content.layer.borderWidth = 1.0;
    content.backgroundColor = [UIColor whiteColor];
	// Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    UITextView *email_field = (UITextView *)[self.view viewWithTag:100];
    UITextView *content = (UITextView *)[self.view viewWithTag:101];
   
    if ([email_field isFirstResponder] && [touch view] != email_field) {
        [email_field resignFirstResponder];
    }
    
    if ([content isFirstResponder] && [touch view] != content) {
        [content resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITextView *content = (UITextView *)[self.view viewWithTag:101];
    [content becomeFirstResponder];
    return YES;
}

-(IBAction)sendEmail:(id)selector {
    UITextView *email_field = (UITextView *)[self.view viewWithTag:100];
    UITextView *content = (UITextView *)[self.view viewWithTag:101];
    UILabel *error_indicator = (UILabel *)[self.view viewWithTag:200];
    
    NSString *email_value = [email_field text];
    
    NSString *email_regex = @".+@.+";
    NSPredicate *email_predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", email_regex];

    BOOL has_error = FALSE;
    if ([email_predicate evaluateWithObject:email_value] == YES) {
        error_indicator.hidden = TRUE;
    }
    else {
        has_error = TRUE;
        error_indicator.hidden = FALSE;
    }
    
    if (has_error) {
        return;
    }
    
    self.rest = [[REST alloc] init];
    self.rest.delegate = self;
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:email_value forKey:@"to"];
    [data setObject:[content text] forKey:@"comment"];
    
    NSString *url = [NSString stringWithFormat:@"/api/v1/spot/%@/share", self.space.remote_id];
    [self.rest putURL:url withBody:[data JSONRepresentation]];    
}

-(void)requestFromREST:(ASIHTTPRequest *)request {
    [self.navigationController popViewControllerAnimated:TRUE];
}

@end
