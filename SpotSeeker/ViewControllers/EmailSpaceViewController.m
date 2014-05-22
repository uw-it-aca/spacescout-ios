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
@synthesize email_list;
@synthesize existing_emails;
@synthesize to_cell_size;
@synthesize has_valid_to_email;
@synthesize current_selected_email_tag;
@synthesize all_contacts;
@synthesize search_matches;

const CGFloat MARGIN_LEFT = 42.0;
const CGFloat MARGIN_RIGHT = 32.0;
const CGFloat MARGIN_TOP = 11.0;
const CGFloat TEXT_FIELD_LIMIT = 0.30;
const CGFloat TEXTFIELD_Y_INSET = 3.5;
const int TO_EMAIL_TAG_STARTING_INDEX = 1200;
const int SEARCH_TABLE_TAG = 1000;
const int PADDING_BETWEEN_EMAIL_ROWS = 2;

- (void)viewDidLoad
{
    [super viewDidLoad];

    email_list = [[NSMutableArray alloc] init];
    existing_emails = [[NSMutableDictionary alloc] init];
    has_valid_to_email = FALSE;
    
    room_label.text = self.space.name;
    building_label.text = [NSString stringWithFormat:@"%@, %@", space.building_name, space.floor];

    [self loadAllContacts];
}

-(void)viewDidAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"current_user_email"]) {
        NSString *email =[defaults objectForKey:@"current_user_email"];
        UITextView *from = (UITextView *)[self.view viewWithTag:102];
        [from setText: email];
    }
    else if ([defaults objectForKey:@"current_user_login"]) {
        // Eh
        NSString *from_str = [NSString stringWithFormat:@"%@@uw.edu", [defaults objectForKey:@"current_user_login"]];
        UITextView *from = (UITextView *)[self.view viewWithTag:102];
        [from setText:from_str];
    }

    
    // Make this act like the email app - start with the to: focused
    UITextField *to = (UITextField *)[self.view viewWithTag:100];
    [to becomeFirstResponder];
    
    [super viewDidAppear:animated];
}

// This is so we can search though them in the autocomplete
-(void)loadAllContacts {
    
    // If we've been rejected, bail out quick.
    if ( ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusNotDetermined && ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized ) {
        self.all_contacts = [[NSArray alloc] init];
        return;
    }
    
    CFErrorRef error;
    ABAddressBookRef allPeople = ABAddressBookCreateWithOptions(nil, &error);

    // If we don't request access, the auto-complete doesn't have access.
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(allPeople, ^(bool granted, CFErrorRef error) {
            // Since we're in a block, call ourselves again - this time it will get down to the work below
            if (granted) {
                [self loadAllContacts];
            }
            else {
                self.all_contacts = [[NSArray alloc] init];
                return;
            }
        });
    }
    
    CFArrayRef allContacts = ABAddressBookCopyArrayOfAllPeople(allPeople);
    CFIndex numberOfContacts  = ABAddressBookGetPersonCount(allPeople);
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
   
    for(int i = 0; i < numberOfContacts; i++){
        NSString *name = @"";
        NSString *first_name = @"";
        NSString *last_name = @"";
        
        ABRecordRef aPerson = CFArrayGetValueAtIndex(allContacts, i);
        ABMultiValueRef fnameProperty = ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
        ABMultiValueRef lnameProperty = ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
        
        ABMultiValueRef emailProperty = ABRecordCopyValue(aPerson, kABPersonEmailProperty);
        
        NSArray *emailArray = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailProperty);
        
        if (fnameProperty != nil) {
            name = [NSString stringWithFormat:@"%@", fnameProperty];
            first_name = [NSString stringWithFormat:@"%@", fnameProperty];
        }
        if (lnameProperty != nil) {
            name = [name stringByAppendingString:[NSString stringWithFormat:@" %@", lnameProperty]];
            last_name = [NSString stringWithFormat:@"%@", lnameProperty];
        }
        
        if ([emailArray count] > 0) {
            for (int i = 0; i < [emailArray count]; i++) {
                [contacts addObject:@{@"name": name, @"first_name": first_name, @"last_name": last_name, @"email": [emailArray objectAtIndex:i]}];
            }
        }
    }
    
    self.all_contacts = contacts;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)isValidEmail:(NSString *)email {
    NSString *email_regex = @".+@.+\\...+";
    NSPredicate *email_predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", email_regex];

    return [email_predicate evaluateWithObject:email];
}

#pragma mark - Methods for handling the autocomplete

-(NSArray *)getContactDataForQuery:(NSString *)query {
    if ([query isEqualToString:@""]) {
        return @[];
    }
    
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:self.all_contacts.count];
    
    for (NSDictionary *contact in self.all_contacts) {
        NSString *last_name = [contact objectForKey:@"first_name"];
        NSString *first_name = [contact objectForKey:@"last_name"];
        NSString *email = [contact objectForKey:@"email"];

        BOOL fname_match = ([first_name rangeOfString:query options:(NSAnchoredSearch | NSCaseInsensitiveSearch)].location == 0);
        BOOL lname_match = ([last_name rangeOfString:query options:(NSAnchoredSearch | NSCaseInsensitiveSearch)].location == 0);
        BOOL email_match = ([email rangeOfString:query options:(NSAnchoredSearch | NSCaseInsensitiveSearch)].location == 0);

        if (fname_match || lname_match || email_match) {
            [results addObject:contact];
        }
    }

    return results;
}

-(void)hideSearchResultsMenu {
    UITableView *results_table = (UITableView *)[self.view viewWithTag:1000];

    if (results_table) {
        results_table.hidden = TRUE;
    }
    
    self.tableView.scrollEnabled = TRUE;
}

-(void)drawAutocompleteForQuery:(NSString *)query {
    NSArray *matches = [self getContactDataForQuery:query];

    self.search_matches = matches;
    UITableView *results_table = (UITableView *)[self.view viewWithTag:1000];

    if (!matches.count) {
        [self hideSearchResultsMenu];
        return;
    }
    if (!results_table) {
        results_table = [[UITableView alloc] init];
        results_table.tag = SEARCH_TABLE_TAG;
        results_table.delegate = self;
        results_table.dataSource = self;
        results_table.scrollEnabled = FALSE;

        [self.view addSubview:results_table];
    }
    // Position this right below the existing To: input
    UITextFieldWithKeypress *to = (UITextFieldWithKeypress *)[self.view viewWithTag:100];
    CGFloat to_bottom = to.frame.origin.y + to.frame.size.height;
    results_table.frame = CGRectMake(0, to_bottom, self.view.frame.size.width, self.view.frame.size.height - to_bottom);

    
    results_table.hidden = false;
    self.tableView.scrollEnabled = false;

    [results_table reloadData];
}

#pragma mark - Methods for handling selected email address / email list

-(void)onTouchEvent:(UITextFieldWithKeypress *)textField {
    if (self.current_selected_email_tag < TO_EMAIL_TAG_STARTING_INDEX) {
        return;
    }
    
    [self deselectCurrentEmail];
    
    UITextFieldWithKeypress *to = (UITextFieldWithKeypress *)[self.view viewWithTag:100];
    [to showCursor];
}

-(void)deselectCurrentEmail {
    UIView *selected = [self.view viewWithTag:self.current_selected_email_tag];
    [self updateEmailContainerAsPlain:selected];
    
    self.current_selected_email_tag = 0;
}

-(void)preChangeKeyEvent:(UITextFieldWithKeypress *)textField isDelete:(BOOL)is_delete {
    if (is_delete) {
        // If there isn't a currently selected email address, and the text field is empty,
        // select the last email in the list.  That way delete, delete ... will remove all
        // emails
        if (!self.current_selected_email_tag) {
            UITextFieldWithKeypress *to = (UITextFieldWithKeypress *)[self.view viewWithTag:100];
            if ([to.text isEqualToString:@""]) {
                if ([self.email_list count]) {
                    self.current_selected_email_tag = TO_EMAIL_TAG_STARTING_INDEX + [self.email_list count] - 1;
                    UIView *email_view = [self.view viewWithTag:self.current_selected_email_tag];
                    [self updateEmailContainerAsSelected:email_view];
                    [to hideCursor];
                    return;
                }
            }
        }
    }
    if (self.current_selected_email_tag < TO_EMAIL_TAG_STARTING_INDEX) {
        return;
    }
    [self removeCurrentlySelectedEmail];
    
    UITextFieldWithKeypress *to = (UITextFieldWithKeypress *)[self.view viewWithTag:100];
    [to showCursor];
}


-(void)removeCurrentlySelectedEmail {
    UIView *container = [self.view viewWithTag:self.current_selected_email_tag];
    UILabel *email_label = (UILabel *)[container viewWithTag:1];
    NSString *email = email_label.text;

    self.current_selected_email_tag = 0;
    [self removeEmailAddress:email];
    
    UITextFieldWithKeypress *to_field = (UITextFieldWithKeypress *)[self.view viewWithTag:100];
    [to_field becomeFirstResponder];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    
    NSString *new_text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *from;
    
    BOOL has_error = FALSE;
   
    if (100 == textField.tag) {
        [self drawAutocompleteForQuery:new_text];
    }
    // Validate to field.
    if (!self.has_valid_to_email) {
        // If we don't have one in the list, and this is the field that's being edited, validate it.
        if (100 == textField.tag) {
            if (![self isValidEmail:new_text]) {
                has_error = TRUE;
            }
        }
        else {
            has_error = TRUE;
        }
    }

    // Validate from
    if (102 == textField.tag) {
        from = new_text;
    }
    else {
        from = ((UITextField *)[self.view viewWithTag:102]).text;
    }
    
    if (![self isValidEmail:from]) {
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

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag != 100) {
        [self hideLastComma];
    }
    else {
        if (!self.current_selected_email_tag) {
            [self showLastComma];
        }
    }
    [self addEmailFromTextField];
    [self selectTableRowForTextInput:textField];

}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    [self hideLastComma];
    [self addEmailFromTextField];

    [self selectTableRowForTextInput:textView];
}

-(void)selectTableRowForTextInput: (UIView *)input {
    UIView *parent = input;
    while (![parent isKindOfClass:[UITableViewCell class]]) {
        parent = parent.superview;
    }
    
    UITableViewCell *cell = (UITableViewCell *)parent;
    NSIndexPath *path = [self.tableView indexPathForCell:cell];

    // Keep some stuff above the text input visible, to make it more clear you can scroll back up.
    if (path.row == 4) {
//        [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else {
        [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch (textField.tag) {
        case 100: {
            if (textField.text && ![textField.text isEqualToString:@""]) {
                [self addEmailFromTextField];
                [self makeEmailFieldFirstResponder];
                return NO;
            }
            // If there's content in the to field, add the email address.
            // Otherwise: From Email to From
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

-(void)addEmailFromSearchSelection:(NSString *)email {
    UITextFieldWithKeypress *textField = (UITextFieldWithKeypress *)[self.view viewWithTag:100];
    textField.text = @"";

    [self hideSearchResultsMenu];
    [self addEmailAddress:email];
    [textField becomeFirstResponder];
}

-(void)addEmailFromTextField {
    UITextFieldWithKeypress *textField = (UITextFieldWithKeypress *)[self.view viewWithTag:100];
    if (textField.text && ![textField.text isEqualToString:@""]) {
        [self addEmailAddress:textField.text];
        textField.text = @"";
    }
}

-(void)addEmailAddress: (NSString *)email {
    NSMutableString *tmp = [email mutableCopy];
    CFStringTrimWhitespace((CFMutableStringRef)tmp);
    email = [tmp copy];
    
    if ([existing_emails objectForKey:email]) {
        return;
    }
    [existing_emails setObject:email forKey:email];
    [email_list addObject:email];
    
    [self setHasValidEmail];
    [self drawEmailAddresses];
    [self validateForm];

}

-(void)removeEmailAddress: (NSString *)email {
    if (![existing_emails objectForKey:email]) {
        return;
    }
    
    [existing_emails removeObjectForKey:email];
    [email_list removeObject:email];
    
    [self setHasValidEmail];
    [self drawEmailAddresses];
    [self validateForm];
}

-(void)validateForm {
    NSString *from = ((UITextField *)[self.view viewWithTag:102]).text;
    [self setHasValidEmail];

    UIBarButtonItem *send_button = self.navigationItem.rightBarButtonItem;
    if ([self isValidEmail:from] && self.has_valid_to_email) {
        send_button.enabled = TRUE;
    }
    else {
        send_button.enabled = FALSE;
    }
}

#pragma mark - Methods for the display of the email list, with styles
-(UILabel *)_getLastEmailComma {
    if (![self.email_list count]) {
        return nil;
    }
    NSInteger tag = [self.email_list count] + TO_EMAIL_TAG_STARTING_INDEX - 1;
    
    UIView *wrapper = [self.view viewWithTag:tag];
    UILabel *comma = (UILabel *)[wrapper viewWithTag:2];

    return comma;
}

-(void)hideLastComma {
    UILabel *comma = [self _getLastEmailComma];
    if (!comma) {
        return;
    }
    comma.hidden = TRUE;
}

-(void)showLastComma {
    UILabel *comma = [self _getLastEmailComma];
    if (!comma) {
        return;
    }
    comma.hidden = FALSE;
}


-(void)updateEmailContainerAsSelected:(UIView *)container {
    UILabel *email_label = (UILabel *)[container viewWithTag:1];
    UILabel *comma_label = (UILabel *)[container viewWithTag:2];
    NSString *email = email_label.text;
    
    if (![self isValidEmail:email]) {
        email_label.textColor = [UIColor whiteColor];
        email_label.layer.cornerRadius = 3.0;
        email_label.layer.backgroundColor = [UIColor purpleColor].CGColor;
        email_label.layer.backgroundColor = [UIColor colorWithRed:81.0/255 green:77.0/255 blue:163.0/255 alpha:1.0].CGColor;
    }
    else {
        email_label.textColor = [UIColor whiteColor];
        email_label.layer.cornerRadius = 3.0;
        email_label.layer.backgroundColor = [UIColor blueColor].CGColor;
        email_label.layer.backgroundColor = [UIColor colorWithRed:81.0/255 green:77.0/255 blue:163.0/255 alpha:1.0].CGColor;
    }
    
    comma_label.hidden = TRUE;
}

-(void)updateEmailContainerAsPlain:(UIView *)container {
    UILabel *email_label = (UILabel *)[container viewWithTag:1];
    UILabel *comma_label = (UILabel *)[container viewWithTag:2];
    
    /*

    NSString *email = email_label.text;
    
    if (![self isValidEmail:email]) {
        email_label.textColor = [UIColor whiteColor];
        email_label.layer.cornerRadius = 3.0;
        email_label.layer.backgroundColor = [UIColor redColor].CGColor;
    }
    else {
        email_label.textColor = [UIColor blueColor];
        email_label.layer.backgroundColor = [UIColor clearColor].CGColor;
    }
     */
    email_label.textColor = [UIColor colorWithRed:81.0/255 green:77.0/255 blue:163.0/255 alpha:1.0];
    
    comma_label.hidden = FALSE;
}


-(void)drawEmailAddresses {
    UIView *new_container = [[UIView alloc] init];
    UIView *to_container = [self.view viewWithTag:800];
    
    CGFloat to_width = to_container.frame.size.width;
    CGFloat available_width = to_width - MARGIN_LEFT;
    
    UILabel *size_label = [[UILabel alloc] init];
    float current_x = MARGIN_LEFT;
    float current_y = MARGIN_TOP;
    NSString *comma_text = @", ";
    
    CGSize bound = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    CGRect comma_frame_size = [comma_text boundingRectWithSize:bound options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: size_label.font} context:nil];
    
    CGFloat comma_width = comma_frame_size.size.width;
    CGFloat comma_height = comma_frame_size.size.height;
    
    CGFloat last_height = 0.0;
    for (int i = 0; i < email_list.count; i++) {
        NSString *email = [email_list objectAtIndex:i];
        UILabel *email_label = [[UILabel alloc] init];
        
        NSString *email_with_formatting = [NSString stringWithFormat:@"%@, ", email];
        email_label.text = email_with_formatting;
        
        CGRect frame_size = [email_with_formatting boundingRectWithSize:bound options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: size_label.font} context:nil];
        
        CGRect email_frame_size = [email boundingRectWithSize:bound options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: size_label.font} context:nil];
        
        
        CGFloat width = frame_size.size.width;
        CGFloat height = frame_size.size.height;
        CGFloat email_width = email_frame_size.size.width;
        CGFloat email_height = email_frame_size.size.height;
        last_height = height;
        
        // Handle overflow...
        if ((width + current_x) > available_width) {
            // Special case though - if they have an entry that's more than... 90? percent
            // of the row, and it doesn't fit - just truncate it.
            if ((current_x - MARGIN_LEFT) < to_width * 0.10) {
                width = available_width - MARGIN_RIGHT;
                email_width = width;
            }
            else {
                current_x = MARGIN_LEFT;
                current_y = current_y + height + PADDING_BETWEEN_EMAIL_ROWS;
            }
        }
        
        if (width > to_width) {
            width = available_width - MARGIN_RIGHT;
            email_width = width;
        }
        
        UIView *email_container = [[UIView alloc] init];
        email_container.tag = TO_EMAIL_TAG_STARTING_INDEX + i;
        
        UILabel *just_email = [[UILabel alloc] init];
        just_email.text = email;
        just_email.tag = 1;
        
        UILabel *comma_label = [[UILabel alloc] init];
        comma_label.text = comma_text;
        comma_label.tag = 2;
        
        [email_container addSubview:just_email];
        [email_container addSubview:comma_label];
        
        email_container.userInteractionEnabled = TRUE;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchToEmail:)];
        [recognizer setNumberOfTapsRequired:1];
        [email_container addGestureRecognizer:recognizer];
        
        just_email.frame = CGRectMake(0, 0, email_width, email_height);
        comma_label.frame = CGRectMake(email_width, 0, comma_width, comma_height);
        email_container.frame = CGRectMake(current_x, current_y, width, height);
        
        current_x += width;
        
        if (email_container.tag == self.current_selected_email_tag) {
            [self updateEmailContainerAsSelected:email_container];
        }
        else {
            [self updateEmailContainerAsPlain:email_container];
        }
        [new_container addSubview:email_container];
    }
    
    // Start by moving the text input field
    // If we're in the last ... 75% of the width, drop down
    UITextFieldWithKeypress *email_field = (UITextFieldWithKeypress *)[self.view viewWithTag:100];
    if (current_x > available_width * TEXT_FIELD_LIMIT) {
        current_x = MARGIN_LEFT;
        current_y = current_y + last_height + PADDING_BETWEEN_EMAIL_ROWS;
    }
    
    // Set the frame for the new container - otherwise touch events don't get through
    CGFloat new_container_height = current_y + email_field.frame.size.height;
    new_container.frame = CGRectMake(0, 0, to_width, new_container_height);
    
    // Have the textfield fill the available width
    CGFloat textfield_width = available_width - current_x;
    // The text input needs to be at a different Y value to offset it properly
    CGFloat textfield_y = current_y - TEXTFIELD_Y_INSET;
    email_field.frame = CGRectMake(current_x, textfield_y, textfield_width, email_field.frame.size.height);
    
    
    // Replace the old list view with the new one
    UIView *existing_container = [to_container viewWithTag:900];
    if (existing_container) {
        [existing_container removeFromSuperview];
    }
    
    new_container.tag = 900;
    [to_container addSubview:new_container];
    [to_container bringSubviewToFront:email_field];
    
    UIButton *add_from_contacts = (UIButton *)[self.view viewWithTag:110];
    [to_container bringSubviewToFront:add_from_contacts];
    
    // Resize our table row...
    self.to_cell_size = current_y + email_field.frame.size.height;
    
    UITableViewCell *to_cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    to_cell.frame = CGRectMake(to_cell.frame.origin.x, to_cell.frame.origin.y, to_cell.frame.size.width, to_cell_size);
    
    // the reloadData is needed, otherwise there's a gap between the first and second cells.
    [self.tableView reloadData];
    // This is needed to keep the first responder status for the input - and becomeFirstResponder doesn't work after the reload data,
    // possibly because of the animation?  this preempts the animation at least.
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];

}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self drawEmailAddresses];
}

#pragma mark - Methods for handling contacts from the chooser

-(IBAction)openContactChooser:(id)selector {
    [self hideSearchResultsMenu];
    [self addEmailFromTextField];

    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
    picker.peoplePickerDelegate = self;
    
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
    
    [self addEmailAddress:email];
    [self makeEmailFieldFirstResponder];

    CFRelease(prop);

    [self dismissViewControllerAnimated:YES completion:^(void){}];
    return NO;
}

-(void)touchToEmail:(UITapGestureRecognizer *)selector {
    if (selector.view.tag < TO_EMAIL_TAG_STARTING_INDEX) {
        return;
    }
    
    UIView *email_container = selector.view;
    
    if (self.current_selected_email_tag) {
        UIView *last_selected = [self.view viewWithTag:self.current_selected_email_tag];
        [self updateEmailContainerAsPlain:last_selected];
    }
    
    self.current_selected_email_tag = selector.view.tag;
    [self updateEmailContainerAsSelected:email_container];
    
    [self addEmailFromTextField];
    UITextFieldWithKeypress *to = (UITextFieldWithKeypress *)[self.view viewWithTag:100];
    [to hideCursor];
    [self showLastComma];
    [to becomeFirstResponder];
}


#pragma mark - General table handling

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == SEARCH_TABLE_TAG) {
        [self searchResultsTableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    else {
        [self primaryTableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == SEARCH_TABLE_TAG) {
        return [self searchResultsTableView:tableView heightForRowAtIndexPath:indexPath];
    }
    else {
        return [self primaryTableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == SEARCH_TABLE_TAG) {
        return [self searchResultsTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - table methods for the search results table
-(UITableViewCell *)searchResultsTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    if (indexPath.row >= self.search_matches.count) {
        return cell;
    }
    NSDictionary *match = [self.search_matches objectAtIndex:indexPath.row];
    cell.textLabel.text = [match objectForKey:@"name"];
    cell.detailTextLabel.text = [match objectForKey:@"email"];
    return cell;
}

-(CGFloat)searchResultsTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void)searchResultsTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [self.search_matches count]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    NSString *email = [[self.search_matches objectAtIndex:indexPath.row] objectForKey:@"email"];
    
    [self addEmailFromSearchSelection:email];
}

#pragma mark - table methods for the primary ui table
-(CGFloat)primaryTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (self.to_cell_size) {
            return self.to_cell_size;
        }
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void)primaryTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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

    // Keep some stuff above the text input visible, to make it more clear you can scroll back up.
    if (indexPath.row == 4) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    // Scrolling the static content cell up into view is weird, so don't do it.

    else if (indexPath.row != 3) {
        [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -

-(void)makeEmailFieldFirstResponder {
    UITextFieldWithKeypress *textField = (UITextFieldWithKeypress *)[self.view viewWithTag:100];
    [textField becomeFirstResponder];
}


-(void)setHasValidEmail {
    self.has_valid_to_email = FALSE;
    for (NSString *email in email_list) {
        if ([self isValidEmail:email]) {
            self.has_valid_to_email = TRUE;
        }
    }
}

#pragma mark - Methods for actually sharing the space

-(IBAction)sendEmail:(id)selector {
    if (self.is_sending_email) {
        return;
    }
    [self addEmailFromTextField];
    
    UITextView *email_field = (UITextView *)[self.view viewWithTag:100];
    UITextView *from_field = (UITextView *)[self.view viewWithTag:102];
    UITextView *subject_field = (UITextView *)[self.view viewWithTag:103];

    UITextView *content = (UITextView *)[self.view viewWithTag:101];
    
    NSString *from_value = [from_field text];
    
    [from_field resignFirstResponder];
    [subject_field resignFirstResponder];
    [email_field resignFirstResponder];
    [content resignFirstResponder];
    
    self.rest = [[REST alloc] init];
    self.rest.delegate = self;
    
    // Make it so we don't double send - the overlay doesn't cover the send button
    self.is_sending_email = TRUE;

    // If someone set a new from email, let's stash that away for the future
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:from_value forKey:@"current_user_email"];
    
    NSDictionary *data = @{@"to": [self email_list],
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


#pragma mark - keep this upright
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

@end
