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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (IBAction)btnClickCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

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
                else {
                    [self addSubSelectionSearchValuesToDictionary:attributes forFilter:filter andKey:search_key];
                }
            }
        }
    }
    MapViewController *map_vc = [self.navigationController.viewControllers objectAtIndex:([self.navigationController.viewControllers count] - 2)];   
    [map_vc runSearchWithAttributes:attributes];
    [self.navigationController popViewControllerAnimated:YES];
}

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
    else {
        [self didSelectSubSelectionRowAtIndexPath:indexPath];
    }
} 

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"filter_options"]) {
        MapFilterDetailsViewController *mfd = [segue destinationViewController];
        mfd.filter = self.current_section;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSData *data_source = [[NSData alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"filter_config" ofType:@"json"]];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSArray *file_data = [parser objectWithData:data_source];

    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    for (NSDictionary *section in file_data) {
        NSMutableDictionary *filter_group = [[NSMutableDictionary alloc] init];
        [filter_group setObject:[section objectForKey:@"title"] forKey:@"title"];
        
        NSMutableArray *filters = [[NSMutableArray alloc] init ];
        
        NSArray *filters_data = [section objectForKey:@"filters"];
        for (NSDictionary *filter in filters_data) {
            NSMutableDictionary *filter_obj = [[NSMutableDictionary alloc] init ];
            [filter_obj setObject:[filter objectForKey:@"title"] forKey:@"title"];
            NSString *search_key = [filter objectForKey:@"search_key"];
            if (search_key != nil) {
                [filter_obj setObject:search_key forKey:@"search_key"];
            }
            NSString *cell_type = [filter objectForKey:@"table_row_type"];
            if (cell_type) {
                [filter_obj setObject:cell_type forKey:@"table_row_type"];
            }
            NSString *default_search_value = [filter objectForKey:@"default_search_value"];
            if (default_search_value != nil) {
                [filter_obj setObject:default_search_value forKey:@"default_search_value"];
            }
            NSString *is_selected = [filter objectForKey:@"is_selected"];
            if (is_selected != nil) {
                [filter_obj setObject:is_selected forKey:@"is_selected"];
            }
            [filter_obj setObject:[filter objectForKey:@"default_selection_label"] forKey:@"default_selection_label"];
            
            NSMutableArray *filter_options = [[NSMutableArray alloc] init ];
            NSArray *options = [filter objectForKey:@"options"];
            for (NSDictionary *option in options) {
                NSMutableDictionary *filter_option = [[NSMutableDictionary alloc] init];
                [filter_option setObject:[option objectForKey:@"title"] forKey:@"title"];
                [filter_option setObject:[option objectForKey:@"short"] forKey:@"short"];
                [filter_option setObject:[NSNumber numberWithBool:FALSE] forKey:@"selected"];
                [filter_option setObject:[option objectForKey:@"search_value"] forKey:@"search_value"];
                [filter_options addObject:filter_option];
            }
            
            [filter_obj setObject:filter_options forKey:@"options"];
            [filters addObject:filter_obj];

        }
        [filter_group setObject:filters forKey:@"filters"];
        [groups addObject:filter_group];

    }
    
    [self.name_filter setDelegate: self];
    

    self.data_sections = groups;

}

/*
 Each filter type needs to implement a method for loading a cell, fetching the value for the cell, and handling any transitions from clicking on the cell
 */

/* Methods for on/off filters */

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

// Handle when some clicks the row - do nothing?  prevent blue selection highlight?
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
            [selected_options addObject:[option objectForKey:@"short"]];
        }
    }
    
    UILabel *selected_label = (UILabel *)[cell viewWithTag:2];
    
    if ([selected_options count]) {
        selected_label.text = [selected_options componentsJoinedByString:@", "];
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

/* These are to handle the text search for spot name */
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

-(IBAction)dismissNameKeyboard:(id)sender {
    [self.name_filter resignFirstResponder];
}




@end
