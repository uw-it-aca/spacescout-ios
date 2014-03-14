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
@synthesize is_sending_email;
@synthesize building_label;
@synthesize room_label;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    room_label.text = self.space.name;
    building_label.text = [NSString stringWithFormat:@"%@, %@", space.building_name, space.floor];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *new_text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *to, *from;
    
    NSString *email_regex = @".+@.+";
    NSPredicate *email_predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", email_regex];
    
    BOOL has_error = FALSE;
   
    // Validate to field.
    if (100 == textField.tag) {
        to = new_text;
    }
    else {
        to = ((UITextField *)[self.view viewWithTag:100]).text;
    }
    if (![email_predicate evaluateWithObject:to]) {
        has_error = TRUE;
    }

    // Validate from
    if (102 == textField.tag) {
        from = new_text;
    }
    else {
        from = ((UITextField *)[self.view viewWithTag:102]).text;
    }
    
    if (![email_predicate evaluateWithObject:from]) {
        has_error = TRUE;
    }

    // Show/hide button
    UIBarButtonItem *send_button = self.navigationItem.rightBarButtonItem;
    if (has_error) {
        send_button.enabled = FALSE;
    }
    else {
        send_button.enabled = TRUE;
    }

    
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch (textField.tag) {
        case 100: {
            // From Email to From
            UITextView *from_field = (UITextView *)[self.view viewWithTag:102];
            [from_field becomeFirstResponder];
            break;
        }
        case 102: {
            // From From to Subject
            UITextView *subject_field = (UITextView *)[self.view viewWithTag:103];
            [subject_field becomeFirstResponder];
            break;
        }
        case 103: {
            // From Subject to Body
            UITextView *body_field = (UITextView *)[self.view viewWithTag:101];
            [body_field becomeFirstResponder];
            break;
        }
    }
    
    return YES;
}

-(IBAction)openContactChooser:(id)selector {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
    picker.peoplePickerDelegate = self;
    
//    [self presentModalViewController:picker animated:YES];
    [self presentViewController:picker animated:YES completion:^(void) {}];
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    CFTypeRef prop = ABRecordCopyValue(person, property);
    CFIndex index = ABMultiValueGetIndexForIdentifier(prop,  identifier);
    NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(prop, index);
    
    UITextView *email_field = (UITextView *)[self.view viewWithTag:100];
    [email_field setText:email];

    CFRelease(prop);

    [self dismissViewControllerAnimated:YES completion:^(void){}];
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            // Select To:
            [[self.view viewWithTag:100] becomeFirstResponder];
            break;
        case 1:
            // Select From:
            [[self.view viewWithTag:102] becomeFirstResponder];
            break;
        case 2:
            // Select Subject:
            [[self.view viewWithTag:103] becomeFirstResponder];
            break;
        case 4:
            // Select content
            [[self.view viewWithTag:101] becomeFirstResponder];
            break;

        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    // get the reference to the text field
 //   [textField setUserInteractionEnabled:YES];
   // [textField becomeFirstResponder];
}

-(IBAction)sendEmail:(id)selector {
    if (self.is_sending_email) {
        return;
    }
    
    UITextView *email_field = (UITextView *)[self.view viewWithTag:100];
    UITextView *from_field = (UITextView *)[self.view viewWithTag:102];
    UITextView *subject_field = (UITextView *)[self.view viewWithTag:103];

    UITextView *content = (UITextView *)[self.view viewWithTag:101];
    
    NSString *email_value = [email_field text];
    NSString *from_value = [from_field text];
    
    [from_field resignFirstResponder];
    [subject_field resignFirstResponder];
    [email_field resignFirstResponder];
    [content resignFirstResponder];
    
    self.rest = [[REST alloc] init];
    self.rest.delegate = self;
    
    // Make it so we don't double send - the overlay doesn't cover the send button
    self.is_sending_email = TRUE;
    
    NSDictionary *data = @{@"to": email_value,
                                  @"comment": [content text],
                                  @"subject": [subject_field text],
                                  @"from": from_value
                                  };
    
    NSString *url = [NSString stringWithFormat:@"/api/v1/spot/%@/share", self.space.remote_id];
    
    if (!self.overlay) {
        self.overlay = [[OverlayMessage alloc] init];
        [self.overlay addTo:self.view];
    }
    [self.overlay showOverlay:@"Sending..." animateDisplay:YES afterShowBlock:^(void) {
        [self.rest putURL:url withBody:[data JSONRepresentation]];
    }];
}

-(void)requestFromREST:(ASIHTTPRequest *)request {
    
    [self.overlay showOverlay:@"Email sent!" animateDisplay:NO afterShowBlock:^(void) {}];
    [self.overlay setImage: [UIImage imageNamed:@"GreenCheckmark"]];

    [self.overlay hideOverlayAfterDelay:1.0 animateHide:YES afterHideBlock:^(void) {
        [self.navigationController popViewControllerAnimated:TRUE];
        self.is_sending_email = FALSE;
    }];
}

@end
