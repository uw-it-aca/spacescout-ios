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
}

@end

@implementation MoreViewController

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

@end
