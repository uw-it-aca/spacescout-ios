//
//  MapFilterPickerViewController.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapFilterPickerViewController.h"

@implementation MapFilterPickerViewController

@synthesize filter_picker;
@synthesize filter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_prototype"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell_prototype"];
    }

    UILabel *cell_label = (UILabel *)[cell viewWithTag:1];
    
    if (indexPath.row == 0) {
        cell_label.text = [self.filter objectForKey:@"no_selection_label"];        
        if ([self.filter objectForKey:@"selected_row"] == nil) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    else {
        cell_label.text = [self.filter objectForKey:@"show_chooser_label"];   
        if ([self.filter objectForKey:@"selected_row"]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        self.filter_picker.hidden = true;
        NSIndexPath *other_row = [NSIndexPath indexPathForRow:1 inSection:0];
        [[tableView cellForRowAtIndexPath:other_row] setAccessoryType:UITableViewCellAccessoryNone];        
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self.filter removeObjectForKey:@"selected_row"];
    }
    else {
        NSIndexPath *other_row = [NSIndexPath indexPathForRow:0 inSection:0];
        [[tableView cellForRowAtIndexPath:other_row] setAccessoryType:UITableViewCellAccessoryNone];
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];

        [self.filter setObject:[[NSNumber alloc] initWithInteger:0] forKey:@"selected_row"];
        [self.filter_picker selectRow:0 inComponent:0 animated:FALSE];
        
        self.filter_picker.hidden = false; 

    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[self.filter objectForKey:@"options"] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[[self.filter objectForKey:@"options"] objectAtIndex:row] objectForKey:@"title"];
} 

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.filter setObject:[[NSNumber alloc] initWithInteger:row] forKey:@"selected_row"];
}

- (void) viewDidAppear:(BOOL)animated {

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    	// Do any additional setup after loading the view.
    [self.filter_picker reloadAllComponents];
    NSNumber *selected_row = [self.filter objectForKey:@"selected_row"];
    if (selected_row == nil) {
        self.filter_picker.hidden = true;
    }
    else {
        self.filter_picker.hidden = false;
        NSInteger current_row = [selected_row  integerValue];
        [self.filter_picker selectRow:current_row inComponent:0 animated:FALSE];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
