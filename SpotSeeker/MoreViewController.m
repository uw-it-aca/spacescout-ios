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
    MFMailComposeViewController *mailComposer;
}

@end

@implementation MoreViewController
@synthesize contactView;


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
    self.contactView.delegate = self;
    self.contactView.dataSource = self;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [contacts count] * 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    BOOL isDescription = (indexPath.row % 2 != 0);
    int contactIndex = indexPath.row;
    
    if (isDescription)
        contactIndex -= 1;

    Contact *contact = [contacts objectAtIndex:contactIndex];

    if (isDescription) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ContactDescriptionCell" forIndexPath:indexPath];
        cell.textLabel.text = contact.description;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
        cell.textLabel.text = contact.title;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 != 0) {
        return;
    }
    
    Contact *contact = [contacts objectAtIndex:indexPath.row];
    mailComposer = [[MFMailComposeViewController alloc]init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setToRecipients:contact.email_to];
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendFormat:@"[%s] %s",
     [[contact.type capitalizedString] UTF8String],
     [contact.title UTF8String]];
    [mailComposer setSubject:string];
    [string setString:@""];
    if ([contact.email_prefix length]) {
        [string appendFormat:@"(%s)\n\n", [contact.email_prefix UTF8String]];
    }

    for (id field in contact.fields) {
        NSString *name = [field objectForKey:@"name"];
        if ([name length]) {
            if ([[field objectForKey:@"required"] boolValue]) {
                [string appendFormat:@"%s: \n", [name UTF8String]];
            } else {
                [string appendFormat:@"%s (optional): \n", [name UTF8String]];
            }
        }
    }

    if ([contact.email_postfix length]) {
        [string appendFormat:@"\n(%s)", [contact.email_postfix UTF8String]];
    }
    
    [mailComposer setMessageBody:string isHTML:NO];
    [self presentModalViewController:mailComposer animated:YES];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
    }
    [super viewWillDisappear:animated];
 
    int row = [self.campusPicker selectedRowInComponent:0];
    Campus *campus = [[Campus getCampuses] objectAtIndex:row];
    Campus *current_campus = [Campus getCurrentCampus];
    
    if ([current_campus.search_key isEqualToString:campus.search_key]) {
        return;
    }

    [Campus setCurrentCampus: campus];
}

-(void)sendSuggestion:(id)sender {
    mailComposer = [[MFMailComposeViewController alloc]init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setSubject:@"Test mail"];
    [mailComposer setMessageBody:@"Testing message for the test mail" isHTML:NO];
    [self presentModalViewController:mailComposer animated:YES];
}

#pragma mark - mail compose delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result) {
        NSLog(@"Result : %d",result);
    }
    if (error) {
        NSLog(@"Error : %@",error);
    }

    [self dismissModalViewControllerAnimated:YES];
}

@end
