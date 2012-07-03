//
//  PickerFilterViewController.m
//  SpaceScout
//
//  Created by Patrick Michaud on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PickerFilterViewController.h"

@interface PickerFilterViewController ()

@end

@implementation PickerFilterViewController

@synthesize filter;
@synthesize table;
@synthesize picker;

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
	// Do any additional setup after loading the view.
    [self.picker selectRow:[[self.filter objectForKey:@"selected_row"] intValue]  inComponent:0 animated:NO];
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

#pragma mark -
#pragma mark picker methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[self.filter objectForKey:@"options"] count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[[self.filter objectForKey:@"options"] objectAtIndex:row] objectForKey:@"title"];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.table cellForRowAtIndexPath:indexPath];
    UIButton *filter_selection = (UIButton *)[cell viewWithTag:3];
    
    NSMutableDictionary *current_obj = self.filter;
    [current_obj setObject:[NSNumber numberWithInt:row]  forKey:@"selected_row"];
    
    NSString *title = [[[current_obj objectForKey:@"options"] objectAtIndex:row] objectForKey:@"title"];
    [filter_selection setTitle:title forState:UIControlStateNormal];

}

#pragma mark -
#pragma mark table methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"display_cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"display_cell"];
    }

    UILabel *filter_label = (UILabel *)[cell viewWithTag:1];
    
    NSMutableDictionary *current_obj = self.filter;
    NSString *label_key = [NSString stringWithFormat:@"Search screen label %@", [current_obj objectForKey:@"search_key"]];   
    filter_label.text = NSLocalizedString(label_key, nil);
    
    UIButton *filter_selection = (UIButton *)[cell viewWithTag:3];
    
    NSNumber *selected_row = [current_obj objectForKey:@"selected_row"];
    if (selected_row == nil) {
        [filter_selection setTitle:[current_obj objectForKey:@"no_selection_label"] forState:UIControlStateNormal];
    }
    else {
        NSInteger current_row = [selected_row  integerValue];
        NSString *title = [[[current_obj objectForKey:@"options"] objectAtIndex:current_row] objectForKey:@"title"];
        [filter_selection setTitle:title forState:UIControlStateNormal];
    }
    
    UILabel *value_label = (UILabel *)[cell viewWithTag:2];
    NSString *value_label_key = [NSString stringWithFormat:@"Search screen label title %@", [current_obj objectForKey:@"search_key"]];   
    value_label.text = NSLocalizedString(value_label_key, nil);
    
    return cell;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

@end
