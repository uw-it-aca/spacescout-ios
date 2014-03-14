//
//  SearchableIndexedTableFilterViewController.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 6/8/12.
//  Copyright (c) 2012, 2013 University of Washington. All rights reserved.
//

#import "SearchableIndexedTableFilterViewController.h"

@implementation SearchableIndexedTableFilterViewController

@synthesize filter;
@synthesize table_view;
@synthesize search_bar;
@synthesize index_data;
@synthesize search_display_controller;
@synthesize search_results;
@synthesize search_bar_cell;
@synthesize did_cancel;
@synthesize loading_spinner;
@synthesize rest;

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

    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
    
    float red_value = [[plist_values objectForKey:@"nav_cancel_button_color_red"] floatValue];
    float green_value = [[plist_values objectForKey:@"nav_cancel_button_color_green"] floatValue];
    float blue_value = [[plist_values objectForKey:@"nav_cancel_button_color_blue"] floatValue];
    
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:red_value / 255.0 green:green_value / 255.0 blue:blue_value / 255.0 alpha:1.0];

    
    self.rest = [[REST alloc] init];
    if ([filter objectForKey:@"data_source"] && [[filter objectForKey:@"options"] count] == 0) {
        self.table_view.hidden = YES;
        UIView *overlay = [self.view viewWithTag:100];
        overlay.hidden = NO;
        
        NSString *building_url = [NSString stringWithFormat:[filter objectForKey:@"data_source"], [Campus getCurrentCampus].search_key];
        
        __weak ASIHTTPRequest *request = [rest getRequestForBlocksWithURL:building_url];
        
        [request setCompletionBlock:^{
            overlay.hidden = TRUE;
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            
            if (200 != [request responseStatusCode]) {
                NSLog(@"Code: %i", [request responseStatusCode]);
                // show an error
            }
            
            NSArray *buildings = [parser objectWithData:[request responseData]];
            NSMutableArray *options = [[NSMutableArray alloc] init];
            for (NSString *building in buildings) {
                if (![building isEqualToString:@""]) {
                    NSMutableDictionary *building_options = [[NSMutableDictionary alloc] init];
                    [building_options setObject:building forKey:@"title"];
                    [building_options setObject:building forKey:@"search_value"];
                    
                    [options addObject:building_options];
                }
            }
            [self.filter setObject:options forKey:@"options"];
            
            self.index_data = [self createTableIndex];
            [self.table_view reloadData];
            self.loading_spinner.hidden = YES;
            self.table_view.hidden = NO;

        }];

        [request startAsynchronous];
    }
    else {
        self.index_data = [self createTableIndex];
    }
    
    self.search_display_controller = [[UISearchDisplayController alloc] initWithSearchBar:self.search_bar contentsController:self];
    self.search_display_controller.delegate = self;
    self.search_display_controller.searchResultsDataSource = self;
    self.search_display_controller.searchResultsDelegate = self;
    self.search_bar.scopeButtonTitles = nil;
    
    NSString *screen_title = [self.filter objectForKey:@"screen_title"];
    self.title = screen_title;

    self.screenName = [NSString stringWithFormat:@"Searchable Indexed Table Filter View (%@)", screen_title];

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

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -
#pragma mark building the index

-(NSMutableDictionary *)createTableIndex {
    NSMutableArray *filter_sections = [[NSMutableArray alloc] init];
    NSMutableDictionary *current_section;
    NSMutableDictionary *index_to_section = [[NSMutableDictionary alloc] init];
    
    NSString *current_index = @"";
    
    NSArray *options = [filter objectForKey:@"options"];

    NSInteger section_index = 0;
    NSInteger row_count = 0;
    // Sort the options here, create a list of option->index mappings?
    for (int index = 0; index < [options count]; index++) {
        NSMutableDictionary *building = [options objectAtIndex:index];
        NSString *option = [building objectForKey:@"title"];
        
        NSString *option_index = [option substringToIndex:1];
        if (![option_index isEqualToString:current_index]) {
            if (current_section != nil) {
                [filter_sections addObject:current_section];
            }
            current_section = [self createfilterSection];
            [current_section setObject:option_index forKey:@"title"];
            current_index = option_index;
            
            section_index++;
            row_count = 0;
            [index_to_section setObject:[NSNumber numberWithInt:section_index] forKey:option_index];
        }
        
        [building setObject:[NSNumber numberWithInt:index] forKey:@"array_index"];
        
        if ([[building objectForKey:@"selected"] intValue] > 0) {
            [building setObject:[NSNumber numberWithInt:1] forKey:@"checked"];
        }
        
        NSIndexPath *index_path = [NSIndexPath indexPathForRow:row_count inSection:section_index];
        [building setObject:index_path forKey:@"index_path"];
        NSMutableArray *values = [current_section objectForKey:@"values"];
        [values addObject:building]; 
        row_count++;
    }
    
    [filter_sections addObject:current_section];
    
    NSMutableDictionary *index = [[NSMutableDictionary alloc] init];
    [index setObject:filter_sections forKey:@"sections"];
    [index setObject:[self filterSectionTitles] forKey:@"section_titles"];
    [index setObject:index_to_section forKey:@"section_lookup"];
    
    return index;
}

-(NSArray *)filterSectionTitles {
    return [[NSArray alloc] initWithObjects:@"#",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
}
    
     
-(NSMutableDictionary *)createfilterSection {
    NSMutableDictionary *section = [[NSMutableDictionary alloc] init];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    [section setObject:values forKey:@"values"];
    [section setObject:@"" forKey:@"title"];
    return section;
}

#pragma mark -
#pragma mark table methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.search_display_controller.searchResultsTableView) {
        return [self searchTableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    else {
        return [self listTableView:tableView didSelectRowAtIndexPath:indexPath];
    }
 
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.search_display_controller.searchResultsTableView) {
        return [self numberofSectionsInSearchTableView:tableView];
    }
    else {
        return [self numberOfSectionsInListTableView:tableView];
    }
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.search_display_controller.searchResultsTableView) {
        return [self searchTableView:tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath];
    }
    else {
        return [self listTableView:tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath];
    }   
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.search_display_controller.searchResultsTableView) {
        return [self searchTableView:tableView numberOfRowsInSection:section];
    }
    else {
        return [self listTableView:tableView numberOfRowsInSection:section];
    }    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
    
    float selected_red_value = [[plist_values objectForKey:@"filter_row_selected_red"] floatValue];
    float selected_green_value = [[plist_values objectForKey:@"filter_row_selected_green"] floatValue];
    float selected_blue_value = [[plist_values objectForKey:@"filter_row_selected_blue"] floatValue];
    
    UIColor *selected_row_color = [UIColor colorWithRed:selected_red_value / 255.0 green:selected_green_value / 255.0 blue:selected_blue_value / 255.0 alpha:1.0];
    
    float unselected_red_value = [[plist_values objectForKey:@"filter_row_unselected_red"] floatValue];
    float unselected_green_value = [[plist_values objectForKey:@"filter_row_unselected_green"] floatValue];
    float unselected_blue_value = [[plist_values objectForKey:@"filter_row_unselected_blue"] floatValue];
    
    UIColor *unselected_row_color = [UIColor colorWithRed:unselected_red_value / 255.0 green:unselected_green_value / 255.0 blue:unselected_blue_value / 255.0 alpha:1.0];
    

    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        [cell setBackgroundColor:selected_row_color];
    }
    else {
        [cell setBackgroundColor:unselected_row_color];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.search_display_controller.searchResultsTableView) {
        return [self searchTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    else {
        UITableViewCell *cell = [self listTableView:tableView cellForRowAtIndexPath:indexPath];
        return cell;
    }    
}

#pragma mark -
#pragma mark search results table methods

-(float)searchTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.table_view dequeueReusableCellWithIdentifier:@"search_results_cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"search_results_cell"];
    }
    UILabel *option = (UILabel *)[cell viewWithTag:5];
    
    NSString *result = [[self.search_results objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    CGFloat expected_height = [result boundingRectWithSize:CGSizeMake(option.frame.size.width, 500.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: option.font } context:nil].size.height;

    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
    
    float padding = [[plist_values objectForKey:@"building_filter_cell_padding"] floatValue];
    
    return expected_height + padding;
}

-(void)searchTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *hit = [self.search_results objectAtIndex:indexPath.row];

    NSIndexPath *hit_index_path = [hit objectForKey:@"index_path"];
    
    [self.search_bar resignFirstResponder];
    [self.search_display_controller setActive:NO animated:YES];

    [self createTableIndex];
    
    [hit setObject:[NSNumber numberWithInt:1] forKey:@"checked"];

    [self.table_view scrollToRowAtIndexPath:hit_index_path atScrollPosition:UITableViewScrollPositionTop animated:NO];

    // Force the cell to re-render, so it has the checkmark and background color
    [self.table_view reloadRowsAtIndexPaths:[NSArray arrayWithObject:hit_index_path] withRowAnimation:FALSE];
}

-(NSInteger)numberofSectionsInSearchTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)searchTableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.search_results count];
}

-(UITableViewCell *)searchTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.table_view dequeueReusableCellWithIdentifier:@"search_results_cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"search_results_cell"];
    }
    UILabel *option = (UILabel *)[cell viewWithTag:5];
    
    NSString *result = [[self.search_results objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    CGFloat expected_height = [result boundingRectWithSize:CGSizeMake(option.frame.size.width, 500.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: option.font } context:nil].size.height;
   
    option.frame = CGRectMake(option.frame.origin.x, option.frame.origin.y, option.frame.size.width, expected_height);
    option.text = result;
    return cell;
}

#pragma mark -
#pragma mark main list table methods

-(float)listTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clear_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clear_cell"];
        }
        
        return cell.frame.size.height;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"content_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"content_cell"];
        }
        UILabel *option = (UILabel *)[cell viewWithTag:15];
        NSArray *values =[[[self.index_data objectForKey:@"sections"] objectAtIndex:indexPath.section - 1] objectForKey:@"values"]; 
        
        NSMutableDictionary *building = [values objectAtIndex:indexPath.row];
        
        CGSize expected = [[building objectForKey:@"title"] sizeWithFont:option.font constrainedToSize:CGSizeMake(option.frame.size.width, 500) lineBreakMode:option.lineBreakMode];
        
        NSString *app_path = [[NSBundle mainBundle] bundlePath];
        NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
        NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
        
        float padding = [[plist_values objectForKey:@"building_filter_cell_padding"] floatValue];
        
        return expected.height + padding;
    }
}


-(void)listTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
    
    float selected_red_value = [[plist_values objectForKey:@"filter_row_selected_red"] floatValue];
    float selected_green_value = [[plist_values objectForKey:@"filter_row_selected_green"] floatValue];
    float selected_blue_value = [[plist_values objectForKey:@"filter_row_selected_blue"] floatValue];
    
    UIColor *selected_row_color = [UIColor colorWithRed:selected_red_value / 255.0 green:selected_green_value / 255.0 blue:selected_blue_value / 255.0 alpha:1.0];
    
    float unselected_red_value = [[plist_values objectForKey:@"filter_row_unselected_red"] floatValue];
    float unselected_green_value = [[plist_values objectForKey:@"filter_row_unselected_green"] floatValue];
    float unselected_blue_value = [[plist_values objectForKey:@"filter_row_unselected_blue"] floatValue];
    
    UIColor *unselected_row_color = [UIColor colorWithRed:unselected_red_value / 255.0 green:unselected_green_value / 255.0 blue:unselected_blue_value / 255.0 alpha:1.0];
    
    if (indexPath.section == 0) {
        for (NSMutableDictionary *building in [self.filter objectForKey:@"options"]) {
            if ([[building objectForKey:@"checked"] intValue] > 0) {
                UITableViewCell *cell = [self.table_view cellForRowAtIndexPath:[building objectForKey:@"index_path"]];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell setBackgroundColor:unselected_row_color];
            }
            [building removeObjectForKey:@"checked"];
        }
        UITableViewCell *clicked_cell = [tableView cellForRowAtIndexPath:indexPath];
        [clicked_cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [clicked_cell setBackgroundColor:selected_row_color];
        return;
    }
        
    UITableViewCell *clicked_cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UILabel *label = (UILabel *)[clicked_cell viewWithTag:15];
    NSString *building_name = label.text;
    
    // This really can't be the best way to do this - but to get to the array index, i'd need to iterate over the sections of
    // the table to get the count
    NSPredicate *results_predicate = [NSPredicate predicateWithFormat:@"(title = %@)", building_name];
    NSArray *found_buildings = [[filter objectForKey:@"options"] filteredArrayUsingPredicate:results_predicate];

    for (NSMutableDictionary *building in found_buildings) {
        if ([[building objectForKey:@"checked"] intValue] > 0) {
            [building setObject:[NSNumber numberWithInt:0] forKey:@"checked"];
            [clicked_cell setBackgroundColor:unselected_row_color];
            [clicked_cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        else {
            [building setObject:[NSNumber numberWithInt:1] forKey:@"checked"];
            [clicked_cell setBackgroundColor:selected_row_color];
            [clicked_cell setAccessoryType:UITableViewCellAccessoryCheckmark];

        }
    }
    
    [self selectFirstOptionOnEmptyTable:tableView];
}

-(NSInteger)numberOfSectionsInListTableView:(UITableView *)tableView {
    NSArray *sections = [self.index_data objectForKey:@"sections"];
    return [sections count] + 1;
}

-(NSInteger)listTableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    return [[[[self.index_data objectForKey:@"sections"] objectAtIndex:section - 1] objectForKey:@"values"] count];
}

-(void)selectFirstOptionOnEmptyTable:(UITableView *)tableView {

    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
    
    float selected_red_value = [[plist_values objectForKey:@"filter_row_selected_red"] floatValue];
    float selected_green_value = [[plist_values objectForKey:@"filter_row_selected_green"] floatValue];
    float selected_blue_value = [[plist_values objectForKey:@"filter_row_selected_blue"] floatValue];
    
    UIColor *selected_row_color = [UIColor colorWithRed:selected_red_value / 255.0 green:selected_green_value / 255.0 blue:selected_blue_value / 255.0 alpha:1.0];
    
    float unselected_red_value = [[plist_values objectForKey:@"filter_row_unselected_red"] floatValue];
    float unselected_green_value = [[plist_values objectForKey:@"filter_row_unselected_green"] floatValue];
    float unselected_blue_value = [[plist_values objectForKey:@"filter_row_unselected_blue"] floatValue];
    
    UIColor *unselected_row_color = [UIColor colorWithRed:unselected_red_value / 255.0 green:unselected_green_value / 255.0 blue:unselected_blue_value / 255.0 alpha:1.0];

    
    NSIndexPath *first_index = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:first_index];

    if ([self shouldCheckFirstOptionInList]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [cell setBackgroundColor:selected_row_color];
        
    }
    else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setBackgroundColor:unselected_row_color];

    }
}

-(BOOL)shouldCheckFirstOptionInList {
    NSArray *options = [filter objectForKey:@"options"];

    for (NSMutableDictionary *building in options) {
        if ([[building objectForKey:@"checked"] intValue] > 0) {
            return false;
        }
    }
    return true;
}

-(UITableViewCell *)listTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clear_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clear_cell"];
        }
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        NSString *clear_string = [self.filter objectForKey:@"clear_selections_label"];
        if (clear_string != nil) {
            label.text = clear_string;
        }
        
        if ([self shouldCheckFirstOptionInList]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        return cell;        
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"content_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"content_cell"];
        }
        UILabel *option = (UILabel *)[cell viewWithTag:15];
        NSArray *values =[[[self.index_data objectForKey:@"sections"] objectAtIndex:indexPath.section - 1] objectForKey:@"values"]; 
        
        NSMutableDictionary *building = [values objectAtIndex:indexPath.row];
        CGSize expected = [[building objectForKey:@"title"] sizeWithFont:option.font constrainedToSize:CGSizeMake(option.frame.size.width, 500) lineBreakMode:option.lineBreakMode];

        option.frame = CGRectMake(option.frame.origin.x, option.frame.origin.y, option.frame.size.width, expected.height);
        option.text = [building objectForKey:@"title"];
        
        if ([[building objectForKey:@"checked"] intValue] > 0) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        [cell setBackgroundColor:[UIColor redColor]];
        return cell;        
    }
}

#pragma mark -
#pragma mark table index methods

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.search_display_controller.searchResultsTableView) {
        return nil;
    }
    return [[NSArray alloc] initWithObjects:@"#",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"";
    }
    return [[[self.index_data objectForKey:@"sections"] objectAtIndex:section - 1] objectForKey:@"title"];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (index == 0) {
        [self.table_view scrollRectToVisible:CGRectMake(0.0, 0.0, self.search_bar.frame.size.width, self.search_bar.frame.size.height) animated:NO];
        return -1;
    }
    NSNumber *section = [[self.index_data objectForKey:@"section_lookup"] valueForKey:title];
    if (section != nil) {
        return [section intValue];
    }
    return -1;
}

#pragma mark -
#pragma mark search bar methods

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSPredicate *results_predicate = [NSPredicate predicateWithFormat:@"(title CONTAINS[cd] %@)", searchText];
    self.search_results = [[filter objectForKey:@"options"] filteredArrayUsingPredicate:results_predicate];
}

#pragma mark -
#pragma mark button actions and navigation

-(IBAction)btnClickCancel:(id)sender {
    self.did_cancel = [NSNumber numberWithInt:1];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    for (NSMutableDictionary *building in [self.filter objectForKey:@"options"]) {
        if (self.did_cancel == nil) {
            if ([[building objectForKey:@"checked"] intValue] > 0) {
                [building setObject:[NSNumber numberWithInt:1] forKey:@"selected"];
            }
            else {
                [building setObject:[NSNumber numberWithInt:0] forKey:@"selected"];
                
            }
        }
        [building removeObjectForKey:@"checked"];
    }
}

@end
