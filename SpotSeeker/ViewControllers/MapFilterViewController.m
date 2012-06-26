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
@synthesize picker_view;

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
    NSString *label_key = [NSString stringWithFormat:@"Search screen section title %@", [[self.data_sections objectAtIndex:section] objectForKey:@"section_name"]];   
    return NSLocalizedString(label_key, nil);
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

-(NSString *)getSelectedOptionsStringForLabel:(UILabel *)selected_label andSelectedOptions:(NSArray *)options withTitleLabel:(UILabel *)title_label andFilter:(NSMutableDictionary *)filter {
    NSMutableArray *long_options = [[NSMutableArray alloc] init];
    for (NSDictionary *option in options) {
        NSString *search_key = [option objectForKey:@"search_key"];
        if (search_key == nil) {
            search_key = [filter objectForKey:@"search_key"];
        }
        // XXX - this is an unfortunate thing, but building names really can't be in the localization file.
        NSString *long_string;
        if ([search_key isEqualToString:@"building_name"]) {
            long_string = [option objectForKey:@"title"];
        }
        else {
            NSString *label_key = [NSString stringWithFormat:@"Search option title %@ %@", search_key, [option objectForKey:@"search_value"]];
            long_string = NSLocalizedString(label_key, nil);
        }
        [long_options addObject:long_string];
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
    
    // Build a string of the short values.  If that's still too long, go down to something like "X, Y, 2 more".
    // Assuming that if there are more than 10 options selected, the string will be too long - just cutting down on
    // the number of string length tests.
    NSMutableArray *options_copy = [[NSMutableArray alloc] initWithArray: options];
    int index = 0;
    if ([options count] > 10) {
        [options_copy removeObjectsInRange:NSMakeRange(10, [options count] - 10)];
        index = [options count] - 10;
    }
    for (; index < [options count]; index++) {
        NSMutableArray *short_options = [[NSMutableArray alloc] init];
        for (NSDictionary *option in options_copy) {
            NSString *search_key = [option objectForKey:@"search_key"];
            if (search_key == nil) {
                search_key = [filter objectForKey:@"search_key"];
            }
            
            // XXX - this is an unfortunate thing, but building names really can't be in the localization file.
            NSString *short_string;
            if ([search_key isEqualToString:@"building_name"]) {
                short_string = [option objectForKey:@"short"];
            }
            else {
                NSString *short_key = [NSString stringWithFormat:@"Search option short %@ %@", search_key, [option objectForKey:@"search_value"]];
                short_string = NSLocalizedString(short_key, nil);
            }
            [short_options addObject:short_string];
        }
        NSString *test_string = [short_options componentsJoinedByString:@", "];
        if (index > 0) {
            test_string = [NSString stringWithFormat:@"%@, %i more", test_string, index];
        }
        CGSize short_size = [test_string sizeWithFont:selected_label.font];
        
        if ((title_width + short_size.width + 20) < available_width) {
            return test_string;
        }
        int remove_at = [options_copy count] - 1;
        [options_copy removeObjectAtIndex:remove_at];
    }

    // Oh boy, I guess just tell them how many selected options there are.
    return [NSString stringWithFormat:@"%i selected", [options count]];
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
    
    NSString *label_key = [NSString stringWithFormat:@"Search screen label %@", [current_obj objectForKey:@"search_key"]];   
    filter_label.text = NSLocalizedString(label_key, nil);
    
    UILabel *filter_selection = (UILabel *)[cell viewWithTag:4];
    
    if ([current_obj objectForKey:@"open_until"] != nil) {
        NSString *date_format = [self stringForDateRangeFrom:[current_obj objectForKey:@"open_at"] to:[current_obj objectForKey:@"open_until"]];
        filter_selection.text = [NSString stringWithFormat:@"Open: %@", date_format];
    }
    else if ([current_obj objectForKey:@"open_at"] != nil) {
        NSString *date_format = [self stringForDateComponents:[current_obj objectForKey:@"open_at"]];
        filter_selection.text = [NSString stringWithFormat:@"Open: %@", date_format];
    }
    else {
        filter_selection.text = [current_obj objectForKey:@"default_selection_label"];
    }
    return cell;
    
}

-(NSString *)dayNameForIndex:(NSInteger)weekday {
    NSArray *days = [NSArray arrayWithObjects:@"Sun", @"Mon", @"Tues", @"Wed", @"Thurs", @"Fri", @"Sat", nil];
    return [days objectAtIndex:weekday];
}


-(NSString *)stringForDateComponents:(NSDateComponents *)components {
    if (components == nil) {
        return @"Now";
    }
    int hour = components.hour;
    
    NSString *am_pm;
    if (hour >= 12) {
        am_pm = @"PM";
    }
    else {
        am_pm = @"AM";
    }
    
    if (hour > 12) {
        hour -= 12;
    }
    
    if (hour == 0) {
        hour = 12;
    }
    
    NSString *display = [NSString stringWithFormat:@"%@, %i:%02i %@", [self dayNameForIndex:components.weekday -1], hour, components.minute, am_pm];

    return display;
}

-(NSString *)stringForDateRangeFrom:(NSDateComponents *)starting to:(NSDateComponents *)ending {
    return [NSString stringWithFormat:@"%@ - %@", [self stringForDateComponents:starting], [self stringForDateComponents:ending]];
}

-(NSString *)dayNameForSearchingAtIndex:(NSInteger)weekday {
    NSArray *days = [NSArray arrayWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];
    return [days objectAtIndex:weekday];
}

-(NSString *)stringForSearchingForDateComponents:(NSDateComponents *)components {
    
    NSString *display = [NSString stringWithFormat:@"%@,%02i:%02i", [self dayNameForSearchingAtIndex:components.weekday -1], components.hour, components.minute];
    
    return display;
}


// Fill out the search values
-(void)addTimeSearchValuesToDictionary:(NSMutableDictionary *)attributes forFilter:(NSDictionary *)filter andKey:(NSString *)search_key {
    if ([filter objectForKey:@"open_until"]) {
        NSString *date_string = [self stringForSearchingForDateComponents:[filter objectForKey:@"open_until"]];
        [attributes setObject:[[NSMutableArray alloc] initWithObjects:date_string, nil] forKey: @"open_until"];
        
        NSDateComponents *open_at = [filter objectForKey:@"open_at"];
        if (open_at == nil) {
            NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *now = [NSDate date];
            
           open_at = [cal components:( INT_MAX ) fromDate:now];
        }

        NSString *open_string = [self stringForSearchingForDateComponents:open_at];
        [attributes setObject:[[NSMutableArray alloc] initWithObjects:open_string, nil] forKey: @"open_at"];        
    }
    else if ([filter objectForKey:@"open_at"]) {
        NSString *date_string = [self stringForSearchingForDateComponents:[filter objectForKey:@"open_at"]];
        [attributes setObject:[[NSMutableArray alloc] initWithObjects:date_string, nil] forKey: @"open_at"];

    }
    else {
        [attributes setObject:[[NSMutableArray alloc] initWithObjects:@"1", nil] forKey: @"open_now"];        
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
    
    NSString *label_key = [NSString stringWithFormat:@"Search screen label %@", [current_obj objectForKey:@"search_key"]];   
    filter_label.text = NSLocalizedString(label_key, nil);

    UIButton *filter_selection = (UIButton *)[cell viewWithTag:4];

    NSNumber *selected_row = [current_obj objectForKey:@"selected_row"];
    if (selected_row == nil) {
        [filter_selection setTitle:[current_obj objectForKey:@"no_selection_label"] forState:UIControlStateNormal];
    }
    else {
        NSInteger current_row = [selected_row  integerValue];
        NSString *title = [[[current_obj objectForKey:@"options"] objectAtIndex:current_row] objectForKey:@"title"];
        [filter_selection setTitle:title forState:UIControlStateNormal];
    }
    
    UILabel *value_label = (UILabel *)[cell viewWithTag:5];
    NSString *value_label_key = [NSString stringWithFormat:@"Search screen label title %@", [current_obj objectForKey:@"search_key"]];   
    value_label.text = NSLocalizedString(value_label_key, nil);
    
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
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"PickerView"
                                                      owner:self
                                                    options:nil];
    
    
    self.picker_view = [nibViews objectAtIndex: 0];
    picker_view.frame = CGRectMake(0, 960, 320, 480);
    [self.view addSubview:picker_view];
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                        animations:^{   
                            picker_view.frame = CGRectMake(0, 0, 320, 480);
                        }
                     completion:^(BOOL finished) {
                     }
     ];
    
    [self.filter_table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    [self.view addSubview:picker_view];
    UIPickerView *picker = (UIPickerView *)[picker_view viewWithTag:3];
    picker.delegate = self;
    picker.dataSource = self;
    
    [picker selectRow:[[self.current_section objectForKey:@"selected_row"] intValue] inComponent:0 animated:NO];
    
    UIButton *reset = (UIButton *)[picker_view viewWithTag:1];
    [reset addTarget:self action:@selector(pickerResetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *done = (UIButton *)[picker_view viewWithTag:2];
    [done addTarget:self action:@selector(pickerDoneBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    // This covers the top of the screen
    UIButton *fake_done = (UIButton *)[picker_view viewWithTag:4];
    [fake_done addTarget:self action:@selector(pickerDoneBtnClick:) forControlEvents:UIControlEventTouchUpInside];

}

-(void)pickerResetBtnClick:(id)sender {
    UIPickerView *picker = (UIPickerView *)[self.picker_view viewWithTag:3];
    [picker selectRow:0 inComponent:0 animated:YES];
}

-(void)pickerDoneBtnClick:(id)sender {
    for (NSMutableDictionary *option in [self.current_section objectForKey:@"options"]) {
        [option setValue:[NSNumber numberWithBool:FALSE] forKey:@"selected"];
    }

    UIPickerView *picker = (UIPickerView *)[self.picker_view viewWithTag:3];
    NSMutableDictionary *chosen = [[self.current_section objectForKey:@"options"] objectAtIndex:[picker selectedRowInComponent:0]];
    [chosen setValue:[NSNumber numberWithBool:FALSE] forKey:@"selected"];

    [self.current_section setObject:[NSNumber numberWithInt:[picker selectedRowInComponent:0]] forKey:@"selected_row"];
    [self.filter_table reloadData];
    
    [UIView animateWithDuration:0.8
                          delay:0.2
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         picker_view.frame = CGRectMake(0, 960, 320, 480);
                     } 
                     completion:^(BOOL finished){
                         [self.picker_view removeFromSuperview];

                     }];
    
    
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[self.current_section objectForKey:@"options"] count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[[self.current_section objectForKey:@"options"] objectAtIndex:row] objectForKey:@"title"];
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
    
    NSString *label_key = [NSString stringWithFormat:@"Search screen label %@", [current_obj objectForKey:@"search_key"]];   
    filter_label.text = NSLocalizedString(label_key, nil);
    
    NSMutableArray *selected_options = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *option in (NSMutableArray *)[current_obj objectForKey:@"options"]) {
        if ([[option objectForKey:@"selected"] boolValue]) {
            [selected_options addObject:option];
        }
    }
    
    UILabel *selected_label = (UILabel *)[cell viewWithTag:2];
    
    if ([selected_options count]) {
        NSString *label = [self getSelectedOptionsStringForLabel:selected_label andSelectedOptions:selected_options withTitleLabel:filter_label andFilter:current_obj];
        selected_label.text = label;
    }
    else {
        NSString *default_key = [NSString stringWithFormat:@"Search screen default label %@", [current_obj objectForKey:@"search_key"]];
        selected_label.text = NSLocalizedString(default_key, nil);
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
    
    BOOL has_search_values = false;
    for (NSDictionary *option in options) {
        if ([[option objectForKey:@"selected"] boolValue]) {
            NSString *search_value = [option objectForKey:@"search_value"];
            NSString *search_key   = [option objectForKey:@"search_key"];
            
            if (search_value != nil) {
                has_search_values = true;
                // A row can either add options to the group, or be independent.
                if (search_key != nil) {
                    [attributes setObject:[[NSArray alloc] initWithObjects:search_value, nil] forKey:search_key];
                }
                else {
                    [selected_options addObject:search_value];
                }
            }
        }
    }
    if ([selected_options count]) {
        [attributes setObject:selected_options forKey:search_key];
    }
    else if (has_search_values == false) {
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
    
    NSString *label_key = [NSString stringWithFormat:@"Search screen label %@", [current_obj objectForKey:@"search_key"]];   
    filter_label.text = NSLocalizedString(label_key, nil);
    
    NSMutableArray *selected_options = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *option in (NSMutableArray *)[current_obj objectForKey:@"options"]) {
        if ([[option objectForKey:@"selected"] boolValue]) {
            [selected_options addObject:option];
        }
    }
    
    
    UILabel *selected_label = (UILabel *)[cell viewWithTag:2];
    
    if ([selected_options count]) {
        NSString *label = [self getSelectedOptionsStringForLabel:selected_label andSelectedOptions:selected_options withTitleLabel:filter_label andFilter:current_obj];
        selected_label.text = label;
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
