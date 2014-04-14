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
const CGFloat MARGIN_RIGHT = 0.0;
const CGFloat MARGIN_TOP = 11.0;
const CGFloat TEXT_FIELD_LIMIT = 0.75;
const CGFloat TEXTFIELD_Y_INSET = 3.5;
const int TO_EMAIL_TAG_STARTING_INDEX = 1200;
const int SEARCH_TABLE_TAG = 1000;

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

// This is so we can search though them in the autocomplete
-(void)loadAllContacts {
    
    CFErrorRef error;
    ABAddressBookRef allPeople = ABAddressBookCreateWithOptions(nil, &error);
//    ABAddressBookRef allPeople = ABAddressBookCreate();
    CFArrayRef allContacts = ABAddressBookCopyArrayOfAllPeople(allPeople);
    CFIndex numberOfContacts  = ABAddressBookGetPersonCount(allPeople);
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
   
    for(int i = 0; i < numberOfContacts; i++){
        NSString* name = @"";
        
        ABRecordRef aPerson = CFArrayGetValueAtIndex(allContacts, i);
        ABMultiValueRef fnameProperty = ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
        ABMultiValueRef lnameProperty = ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
        
        ABMultiValueRef emailProperty = ABRecordCopyValue(aPerson, kABPersonEmailProperty);
        
        NSArray *emailArray = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailProperty);
        
        if (fnameProperty != nil) {
            name = [NSString stringWithFormat:@"%@", fnameProperty];
        }
        if (lnameProperty != nil) {
            name = [name stringByAppendingString:[NSString stringWithFormat:@" %@", lnameProperty]];
        }
        
        if ([emailArray count] > 0) {
            for (int i = 0; i < [emailArray count]; i++) {
                [contacts addObject:@{@"name": name, @"email": [emailArray objectAtIndex:i]}];
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
        NSString *name = [contact objectForKey:@"name"];
        NSString *email = [contact objectForKey:@"email"];
        
        if ([name hasPrefix:query] || [email hasPrefix:query]) {
            [results addObject:contact];
        }
    }

    return results;
    return self.all_contacts;
    return @[@{@"name": @"John Doe", @"email": @"example@example.com" },
             @{@"name": @"Person 2", @"email": @"second@example.com" },
             @{@"name": @"A 3rd", @"email": @"Why not, invalid" },
             ];
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

        // Position this right below the existing To: input
        UITextFieldWithKeypress *to = (UITextFieldWithKeypress *)[self.view viewWithTag:100];
        CGFloat to_bottom = to.frame.origin.y + to.frame.size.height;
        results_table.frame = CGRectMake(0, to_bottom, self.view.frame.size.width, self.view.frame.size.height - to_bottom);
        [self.view addSubview:results_table];
    }
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

-(void)preChangeKeyEvent:(UITextFieldWithKeypress *)textField {
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
    [self addEmailFromTextField];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    [self addEmailFromTextField];
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
    
    UITableView *matches = (UITableView *)[self.view viewWithTag:SEARCH_TABLE_TAG];
    matches.hidden = TRUE;
    
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
}

-(void)removeEmailAddress: (NSString *)email {
    if (![existing_emails objectForKey:email]) {
        return;
    }
    
    [existing_emails removeObjectForKey:email];
    [email_list removeObject:email];
    
    [self setHasValidEmail];
    [self drawEmailAddresses];
}

#pragma mark - Methods for the display of the email list, with styles
-(void)updateEmailContainerAsSelected:(UIView *)container {
    UILabel *email_label = (UILabel *)[container viewWithTag:1];
    UILabel *comma_label = (UILabel *)[container viewWithTag:2];
    NSString *email = email_label.text;
    
    if (![self isValidEmail:email]) {
        email_label.textColor = [UIColor whiteColor];
        email_label.layer.cornerRadius = 3.0;
        email_label.layer.backgroundColor = [UIColor purpleColor].CGColor;
    }
    else {
        email_label.textColor = [UIColor whiteColor];
        email_label.layer.cornerRadius = 3.0;
        email_label.layer.backgroundColor = [UIColor blueColor].CGColor;
    }
    
    comma_label.hidden = TRUE;
}

-(void)updateEmailContainerAsPlain:(UIView *)container {
    UILabel *email_label = (UILabel *)[container viewWithTag:1];
    UILabel *comma_label = (UILabel *)[container viewWithTag:2];
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
    
    comma_label.hidden = FALSE;
}


-(void)drawEmailAddresses {
    UIView *new_container = [[UIView alloc] init];
    UIView *to_container = [self.view viewWithTag:800];
    
    CGFloat to_width = to_container.frame.size.width;
    CGFloat available_width = to_width - MARGIN_LEFT - MARGIN_RIGHT;
    
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
            current_x = MARGIN_LEFT;
            current_y = current_y + height;
        }
        
        if (width > to_width) {
            width = available_width;
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
        current_y = current_y + last_height;
    }
    
    // Set the frame for the new container - otherwise touch events don't get through
    CGFloat new_container_height = current_y + email_field.frame.size.height;
    new_container.frame = CGRectMake(0, 0, to_width, new_container_height);
    
    // Have the textfield fill the available width
    CGFloat textfield_width = available_width - current_x;
    // The text input needs to be at a different Y value to offset it properly
    CGFloat textfield_y = current_y - TEXTFIELD_Y_INSET;
    email_field.frame = CGRectMake(current_x, textfield_y, textfield_width, email_field.frame.size.height);
    
    
    // Resize our table row...
    self.to_cell_size = current_y + email_field.frame.size.height;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
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
    NSLog(@"Body: %@", [request responseString]);
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
