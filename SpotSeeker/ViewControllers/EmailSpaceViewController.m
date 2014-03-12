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
/*
    UITouch *touch = [[event allTouches] anyObject];
    UITextView *email_field = (UITextView *)[self.view viewWithTag:100];
    UITextView *content = (UITextView *)[self.view viewWithTag:101];
   
    if ([email_field isFirstResponder] && [touch view] != email_field) {
        [email_field resignFirstResponder];
    }
    
    if ([content isFirstResponder] && [touch view] != content) {
        [content resignFirstResponder];
    }
  */
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
    UITextView *email_field = (UITextView *)[self.view viewWithTag:100];
    UITextView *from_field = (UITextView *)[self.view viewWithTag:102];
    UITextView *subject_field = (UITextView *)[self.view viewWithTag:103];

    UITextView *content = (UITextView *)[self.view viewWithTag:101];
    UILabel *error_indicator = (UILabel *)[self.view viewWithTag:200];
    UILabel *from_error_indicator = (UILabel *)[self.view viewWithTag:201];
    
    NSString *email_value = [email_field text];
    NSString *from_value = [from_field text];
    
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
 
    if ([email_predicate evaluateWithObject:from_value] == YES) {
        from_error_indicator.hidden = TRUE;
    }
    else {
        has_error = TRUE;
        from_error_indicator.hidden = FALSE;
    }
    
    
    if (has_error) {
        return;
    }
    
    self.rest = [[REST alloc] init];
    self.rest.delegate = self;
    
    NSDictionary *data = @{@"to": email_value,
                                  @"comment": [content text],
                                  @"subject": [subject_field text],
                                  @"from": from_value
                                  };
    
    NSString *url = [NSString stringWithFormat:@"/api/v1/spot/%@/share", self.space.remote_id];
    [self.rest putURL:url withBody:[data JSONRepresentation]];    
}

-(void)requestFromREST:(ASIHTTPRequest *)request {
    [self.navigationController popViewControllerAnimated:TRUE];
}

@end
