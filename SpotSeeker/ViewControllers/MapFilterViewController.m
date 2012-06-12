//
//  MapFilterViewController.m
//  SpotSeeker
//
//  Copyright 2012 UW Information Technology, University of Washington
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MapFilterViewController.h"


@implementation MapFilterViewController

@synthesize spot;
@synthesize name_filter;
@synthesize scroll_view;
@synthesize filter_view;
@synthesize filter_table;
@synthesize data_sections;
@synthesize current_section;
@synthesize user_longitude;
@synthesize user_latitude;
@synthesize user_distance;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidAppear:(BOOL)animated {
    [self.filter_table reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SearchFilter *search_filter = [[SearchFilter alloc] init];
    search_filter.delegate = self;
    [search_filter loadSearchFilters];
    
    
    [self.name_filter setDelegate: self];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)availableFilters:(NSMutableArray *)filters {
    self.data_sections = filters;
}



#pragma mark -
#pragma mark screen actions

- (IBAction)btnClickCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


-(IBAction)btnClickSearch:(id)sender {
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];

    if (self.user_latitude != nil) {
        [attributes setValue:[NSArray arrayWithObjects:self.user_latitude, nil] forKey:@"center_latitude"];
        [attributes setValue:[NSArray arrayWithObjects:self.user_longitude, nil] forKey:@"center_longitude"];
    
        [attributes setValue:[NSArray arrayWithObjects:self.user_distance, nil] forKey:@"distance"];
    }

    if (self.name_filter.text != nil) {
        [attributes setValue:[NSArray arrayWithObjects:self.name_filter.text, nil] forKey:@"name"];
    }
    
   
    for (NSDictionary *section in self.data_sections) {
        NSArray *filters = [section objectForKey:@"filters"];
        for (NSDictionary *filter in filters) {

            NSString *cell_type = [filter objectForKey:@"table_row_type"];
            NSString *search_key = [filter objectForKey:@"search_key"];
            if (search_key != nil) {
                if ([cell_type isEqualToString:@"cell_with_switch"]) {
                    [self addOnOffSearchValuesToDictionary:attributes forFilter:filter andKey:search_key];                    
                }
                else if ([cell_type isEqualToString:@"cell_with_chooser"]) {
                    [self addChooserSearchValuesToDictionary:attributes forFilter:filter andKey:search_key];
                }
                else if ([cell_type isEqualToString:@"cell_with_time"]) {
                    [self addTimeSearchValuesToDictionary:attributes forFilter:filter andKey:search_key];
                }
                else if ([cell_type isEqualToString:@"cell_with_checkbox"]) {
                    [self addCheckboxSearchValuesToDictionary:attributes forFilter:filter andKey:search_key];
                }
                else if ([cell_type isEqualToString:@"cell_with_indexed_table"]) {
                    [self addIndexedTableSearchValuesToDictionary:attributes forFilter:filter andKey:search_key];
                }
                else {
                    [self addSubSelectionSearchValuesToDictionary:attributes forFilter:filter andKey:search_key];
                }
            }
        }
    }

    [delegate runSearchWithAttributes:attributes];
    [self dismissModalViewControllerAnimated:YES];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"filter_options"]) {
        MapFilterDetailsViewController *mfd = [segue destinationViewController];
        mfd.filter = self.current_section;
    }
    else if ([[segue identifier] isEqualToString:@"chooser_options"]) {
        MapFilterPickerViewController *mfp = [segue destinationViewController];
        mfp.filter = self.current_section;
    }
    else if ([[segue identifier] isEqualToString:@"time_options"]) {
        MapFilterTimeViewController *mft = [segue destinationViewController];
        mft.filter = self.current_section;
    }
    else if ([[segue identifier] isEqualToString:@"index_table"]) {
        SearchableIndexedTableFilterViewController *mft = [segue destinationViewController];
        mft.filter = self.current_section;
    }

}

#pragma mark -
#pragma mark table management

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.data_sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.data_sections objectAtIndex:section] objectForKey:@"title"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.data_sections objectAtIndex:section] objectForKey:@"filters"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *current_obj = [[[self.data_sections objectAtIndex:indexPath.section] objectForKey:@"filters"] objectAtIndex:indexPath.row];

    NSString *cell_type = [current_obj objectForKey:@"table_row_type"];
    
    if (cell_type == Nil) {
        cell_type = @"generic_cell";
    }
    

    if ([cell_type isEqualToString:@"cell_with_switch"]) {
        return [self getOnOffCellForFilter:tableView filter:current_obj pathIndex:indexPath];
    }
    else if ([cell_type isEqualToString:@"cell_with_chooser"]) {
        return [self getChooserCellForFilter:tableView filter:current_obj pathIndex:indexPath];
    }
    else if ([cell_type isEqualToString:@"cell_with_time"]) {
        return [self getTimeCellForFilter:tableView filter:current_obj pathIndex:indexPath];
    }
    else if ([cell_type isEqualToString:@"cell_with_checkbox"]) {
        return [self getCheckboxCellForFilter:tableView filter:current_obj pathIndex:indexPath];
    }
    else if ([cell_type isEqualToString:@"cell_with_indexed_table"]) {
        return [self getIndexedTableCellForFilter:tableView filter:current_obj pathIndex:indexPath];
    }
    else {
        return [self getSubSelectionCellForFilter:tableView filter:current_obj pathIndex:indexPath];
    }  

}

         
- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    self.current_section = [[[self.data_sections objectAtIndex:indexPath.section] objectForKey:@"filters"] objectAtIndex:indexPath.row];
    NSString *cell_type = [self.current_section objectForKey:@"table_row_type"];
    
    if ([cell_type isEqualToString:@"cell_with_switch"]) {
        [self didSelectOnOffRowAtIndexPath:indexPath];
    }
    else if ([cell_type isEqualToString:@"cell_with_chooser"]) {
        [self didSelectChooserRowAtIndexPath:indexPath];
    }
    else if ([cell_type isEqualToString:@"cell_with_time"]) {
        [self didSelectTimeRowAtIndexPath:indexPath];
    }
    else if ([cell_type isEqualToString:@"cell_with_checkbox"]) {
        [self didSelectCheckboxRowAtIndexPath:indexPath];
    }
    else if ([cell_type isEqualToString:@"cell_with_indexed_table"]) {
        [self didSelectIndexTableRowAtIndexPath:indexPath];
    }
    else {
        [self didSelectSubSelectionRowAtIndexPath:indexPath];
    }
} 

-(NSString *)getSelectedOptionsStringForLabel:(UILabel *)selected_label andSelectedOptions:(NSArray *)options withTitleLabel:(UILabel *)title_label {
    NSMutableArray *long_options = [[NSMutableArray alloc] init];
    for (NSDictionary *option in options) {
        [long_options addObject:[option objectForKey:@"title"]];
    }

    float left_most = title_label.frame.origin.x;
    float right_most = selected_label.frame.origin.x + selected_label.frame.size.width;
    
    float available_width = right_most - left_most;

    float title_width = [title_label.text sizeWithFont:title_label.font].width;
    
    NSString *long_test = [long_options componentsJoinedByString:@", "];
    CGSize long_size = [long_test sizeWithFont:selected_label.font];
    
    if ((title_width + long_size.width + 20) < available_width) {
        return long_test;
    }
    
    NSMutableArray *short_options = [[NSMutableArray alloc] init];
    for (NSDictionary *option in options) {
        [short_options addObject:[option objectForKey:@"short"]];
    }
    
    return [short_options componentsJoinedByString:@", "];
}

/*
 Each filter type needs to implement a method for loading a cell, fetching the value for the cell, and handling any transitions from clicking on the cell
 */

/* Methods for a row with a check mark */

#pragma mark - 
#pragma mark checkbox rows

-(UITableViewCell *)getCheckboxCellForFilter:(UITableView *)tableView filter:(NSMutableDictionary *)current_obj pathIndex:indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_with_checkbox"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell_with_checkbox"];
    }

    UILabel *filter_label = (UILabel *)[cell viewWithTag:3];
    filter_label.text = [current_obj objectForKey:@"title"];
    
    NSString *current_value = [current_obj objectForKey:@"selected"];
    if ([current_value isEqualToString:@"1"]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    return cell;
}

-(void)didSelectCheckboxRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *filter = [[[self.data_sections objectAtIndex:indexPath.section] objectForKey:@"filters"] objectAtIndex:indexPath.row];
    
    NSString *current_value = [filter objectForKey:@"selected"];
    if ([current_value isEqualToString:@"1"]) {
        [filter setObject:@"" forKey:@"selected"];
        UITableViewCell *current = [filter_table cellForRowAtIndexPath:indexPath];
        [current setAccessoryType:UITableViewCellAccessoryNone];
    }
    else {
        [filter setObject:@"1" forKey:@"selected"];
        UITableViewCell *current = [filter_table cellForRowAtIndexPath:indexPath];
        [current setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
}

-(void)addCheckboxSearchValuesToDictionary:attributes forFilter:filter andKey:search_key {
    
    NSString *is_selected = [filter objectForKey:@"selected"];
    if ([is_selected isEqualToString:@"1"]) {
        [attributes setObject:[[NSMutableArray alloc] initWithObjects:@"1", nil] forKey:search_key];
    }
    
}

/* Methods for choosing a time */
#pragma mark - 
#pragma mark time filter

-(UITableViewCell *)getTimeCellForFilter:(UITableView *)tableView filter:(NSMutableDictionary *)current_obj pathIndex:indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_with_time"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell_with_time"];
    }
    
    UILabel *filter_label = (UILabel *)[cell viewWithTag:3];
    filter_label.text = [current_obj objectForKey:@"title"];      
    
    NSDate *selected_date = [current_obj objectForKey:@"selected_date"];
    UILabel *filter_selection = (UILabel *)[cell viewWithTag:4];
    if (selected_date != nil) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"h:mm a"];
        filter_selection.text = [df stringFromDate:selected_date];            
    }
    else {
        filter_selection.text = @"";
    }
    return cell;
    
}

// Fill out the search values
-(void)addTimeSearchValuesToDictionary:(NSMutableDictionary *)attributes forFilter:(NSDictionary *)filter andKey:(NSString *)search_key {
    NSDate *selected_date = [filter objectForKey:@"selected_date"];
    if (selected_date != nil) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"HH:mm"];
        NSString *search_time = [df stringFromDate:selected_date];            
        NSLog(@"ST: %@", search_time);
        [attributes setObject:[[NSMutableArray alloc] initWithObjects:search_time, nil] forKey: search_key];

    }

}


// Handle when some clicks the row - do nothing?
- (void) didSelectTimeRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"time_options" sender:self];  
}


/* Methods for chooser filters */
#pragma mark - 
#pragma mark table multi-select

-(UITableViewCell *)getChooserCellForFilter:(UITableView *)tableView filter:(NSMutableDictionary *)current_obj pathIndex:indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_with_chooser"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell_with_chooser"];
    }
    
    UILabel *filter_label = (UILabel *)[cell viewWithTag:3];
    filter_label.text = [current_obj objectForKey:@"title"];      

    UILabel *filter_selection = (UILabel *)[cell viewWithTag:4];

    NSNumber *selected_row = [current_obj objectForKey:@"selected_row"];
    if (selected_row == nil) {
        filter_selection.text = [current_obj objectForKey:@"no_selection_label"];

    }
    else {
        NSInteger current_row = [selected_row  integerValue];
        filter_selection.text = [[[current_obj objectForKey:@"options"] objectAtIndex:current_row] objectForKey:@"title"];
    }
    return cell;

}

// Fill out the search values
-(void)addChooserSearchValuesToDictionary:(NSMutableDictionary *)attributes forFilter:(NSDictionary *)filter andKey:(NSString *)search_key {
    NSNumber *selected_row = [filter objectForKey:@"selected_row"];
    if (selected_row == nil) {
        return;
    }
    NSInteger current_row = [[filter objectForKey:@"selected_row"]  integerValue];
    
    if (!current_row) {
        current_row = 0;
    }
    
    NSString *search_value = [[[filter objectForKey:@"options"] objectAtIndex:current_row] objectForKey:@"search_value"];
    
    if (search_value != Nil && ![search_value isEqualToString:@""]) {
        [attributes setObject:[[NSMutableArray alloc] initWithObjects:search_value, nil] forKey: search_key];
    }   
}


// Handle when some clicks the row - do nothing?
- (void) didSelectChooserRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"chooser_options" sender:self];  
}


/* Methods for on/off filters */
#pragma mark - 
#pragma mark on/off filters

// Draw the table cell
-(UITableViewCell *)getOnOffCellForFilter:(UITableView *)tableView filter:(NSMutableDictionary *)current_obj pathIndex:indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_with_switch"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell_with_switch"];
    }

    UILabel *filter_label = (UILabel *)[cell viewWithTag:3];
    filter_label.text = [current_obj objectForKey:@"title"];      
    
    UITableSwitch *on_off = (UITableSwitch *)[cell viewWithTag:4];
    on_off.indexPath = indexPath;
    if ([current_obj objectForKey:@"is_selected"] == Nil) {
        on_off.on = FALSE;
    }
    else {
        on_off.on = TRUE;
    }
    
    [on_off addTarget:self action:@selector(toggleOption:) forControlEvents:(UIControlEventValueChanged | UIControlEventTouchDragInside)];

    return cell;
}

// Handle when some clicks the row - do nothing?
- (void) didSelectOnOffRowAtIndexPath:(NSIndexPath *)indexPath {  
}


// Handle clicking the on/off button

-(void) toggleOption:(id)sender {
    UITableSwitch *ui_switch = (UITableSwitch *)sender;
    NSIndexPath *indexPath = ui_switch.indexPath;
    NSMutableDictionary *current_obj = [[[self.data_sections objectAtIndex:indexPath.section] objectForKey:@"filters"] objectAtIndex:indexPath.row];
    
    [current_obj setValue:[[NSNumber alloc] initWithBool:ui_switch.on] forKey:@"is_selected"];
}

// Fill out the search values
-(void)addOnOffSearchValuesToDictionary:(NSMutableDictionary *)attributes forFilter:(NSDictionary *)filter andKey:(NSString *)search_key {
    NSNumber *is_selected = [filter objectForKey:@"is_selected"];
    if (is_selected != Nil && [is_selected boolValue] == TRUE) {
        [attributes setObject: [[NSMutableArray alloc] initWithObjects:@"1", nil] forKey:search_key];
    }
    
}


/* Methods for sub-selection filters */
#pragma mark - 
#pragma mark sub selection filters

// Draw the table cell
-(UITableViewCell *)getSubSelectionCellForFilter:(UITableView *)tableView filter:(NSMutableDictionary *)current_obj pathIndex:indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"generic_cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"generic_cell"];
    }
    
    UILabel *filter_label = (UILabel *)[cell viewWithTag:1];
    filter_label.text = [current_obj objectForKey:@"title"];
    
    NSMutableArray *selected_options = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *option in (NSMutableArray *)[current_obj objectForKey:@"options"]) {
        if ([[option objectForKey:@"selected"] boolValue]) {
            [selected_options addObject:option];
        }
    }
    
    UILabel *selected_label = (UILabel *)[cell viewWithTag:2];
    
    if ([selected_options count]) {
        NSString *label = [self getSelectedOptionsStringForLabel:selected_label andSelectedOptions:selected_options withTitleLabel:filter_label];
        selected_label.text = label;
    }
    else {
        selected_label.text = [current_obj objectForKey:@"default_selection_label"];
    }
    
    return cell;
}

// Transition to the sub-selections
- (void) didSelectSubSelectionRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"filter_options" sender:self];    
}

// Fill out the search values
-(void)addSubSelectionSearchValuesToDictionary:(NSMutableDictionary *)attributes forFilter:(NSDictionary *)filter andKey:(NSString *)search_key {
    NSMutableArray *selected_options = [[NSMutableArray alloc] init];
    NSArray *options = [filter objectForKey:@"options"];
    for (NSDictionary *option in options) {
        if ([[option objectForKey:@"selected"] boolValue]) {
            NSString *search_value = [option objectForKey:@"search_value"];
            if (search_value != nil) {
                [selected_options addObject:search_value];
            }
        }
    }
    if ([selected_options count]) {
        [attributes setObject:selected_options forKey:search_key];
    }
    else {
        NSString *default_value = [filter objectForKey:@"default_search_value"];
        if (default_value != nil) {
            [attributes setObject: [[NSMutableArray alloc] initWithObjects:default_value, nil] forKey:search_key];
        }
    }   
}

#pragma mark -
#pragma mark indexed table methods

-(UITableViewCell *)getIndexedTableCellForFilter:(UITableView *)tableView filter:(NSMutableDictionary *)current_obj pathIndex:indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_with_indexed_table"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell_with_indexed_table"];
    }
    
    UILabel *filter_label = (UILabel *)[cell viewWithTag:1];
    filter_label.text = [current_obj objectForKey:@"title"];
    
    NSMutableArray *selected_options = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *option in (NSMutableArray *)[current_obj objectForKey:@"options"]) {
        if ([[option objectForKey:@"selected"] boolValue]) {
            [selected_options addObject:option];
        }
    }
    
    
    UILabel *selected_label = (UILabel *)[cell viewWithTag:2];
    
    if ([selected_options count]) {
        NSString *label = [self getSelectedOptionsStringForLabel:selected_label andSelectedOptions:selected_options withTitleLabel:filter_label];
//        NSString *label = [self getSelectedOptionsStringForTitle:[current_obj objectForKey:@"title"] andSelectedOptions:selected_options];
        NSLog(@"Value: %@", label); 
    }
    else {
        selected_label.text = [current_obj objectForKey:@"default_selection_label"];
    }

    return cell;
}

- (void) didSelectIndexTableRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"index_table" sender:self];    
}

-(void)addIndexedTableSearchValuesToDictionary:(NSMutableDictionary *)attributes forFilter:(NSDictionary *)filter andKey:(NSString *)search_key {
    NSMutableArray *selected_options = [[NSMutableArray alloc] init];
    NSArray *options = [filter objectForKey:@"options"];
    for (NSDictionary *option in options) {
        if ([[option objectForKey:@"selected"] boolValue]) {
            NSString *search_value = [option objectForKey:@"search_value"];
            if (search_value != nil) {
                [selected_options addObject:search_value];
            }
        }
    }
    if ([selected_options count]) {
        [attributes setObject:selected_options forKey:search_key];
    }
}

/* These are to handle the text search for spot name */
#pragma mark - 
#pragma mark spot name search

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

-(IBAction)dismissNameKeyboard:(id)sender {
    [self.name_filter resignFirstResponder];
}

@end
