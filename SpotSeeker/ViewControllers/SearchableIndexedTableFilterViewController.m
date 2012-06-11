//
//  SearchableIndexedTableFilterViewController.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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

    self.index_data = [self createTableIndex];
	// Do any additional setup after loading the view.
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
        
        NSIndexPath *index_path = [NSIndexPath indexPathForRow:row_count inSection:section_index];
        [building setObject:index_path forKey:@"index_path"];
        NSMutableArray *values = [current_section objectForKey:@"values"];
        [values addObject:building]; 
        row_count++;
    }
    
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.search_display_controller.searchResultsTableView) {
        return [self searchTableView:tableView numberOfRowsInSection:section];
    }
    else {
        return [self listTableView:tableView numberOfRowsInSection:section];
    }    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.search_display_controller.searchResultsTableView) {
        return [self searchTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    else {
        return [self listTableView:tableView cellForRowAtIndexPath:indexPath];
    }    
}

#pragma mark -
#pragma mark search results table methods

-(void)searchTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *hit = [self.search_results objectAtIndex:indexPath.row];

    NSIndexPath *hit_index_path = [hit objectForKey:@"index_path"];
    
    [self.search_bar resignFirstResponder];
    [self.search_display_controller setActive:NO animated:YES];

    [self createTableIndex];
    
    [hit setObject:[NSNumber numberWithInt:1] forKey:@"checked"];

    [self.table_view scrollToRowAtIndexPath:hit_index_path atScrollPosition:UITableViewScrollPositionTop animated:NO];

    // If the cell is already rendered, we need to add a check here
    UITableViewCell *building_cell = [self.table_view cellForRowAtIndexPath:hit_index_path];
    [building_cell setAccessoryType:UITableViewCellAccessoryCheckmark];

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
    UILabel *option = (UILabel *)[cell viewWithTag:1];

    option.text = [[self.search_results objectAtIndex:indexPath.row] objectForKey:@"title"];
    return cell;
}

#pragma mark -
#pragma mark main list table methods

-(void)listTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(NSInteger)numberOfSectionsInListTableView:(UITableView *)tableView {
    NSArray *sections = [self.index_data objectForKey:@"sections"];
    return [sections count] + 1;
}

-(NSInteger)listTableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    
    return [[[[self.index_data objectForKey:@"sections"] objectAtIndex:section - 1] objectForKey:@"values"] count];
}

-(UITableViewCell *)listTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // If we recreate this, the behavior never gets lined up properly again
            if (self.search_bar_cell != nil) {
                return self.search_bar_cell;
            }
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"search_cell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"search_cell"];
            }
            UISearchBar *bar = (UISearchBar *)[cell viewWithTag:1];
            bar.delegate = self;
            self.search_bar = bar;
            
            self.search_display_controller = [[UISearchDisplayController alloc] initWithSearchBar:bar contentsController:self];
            self.search_display_controller.delegate = self;
            self.search_display_controller.searchResultsDataSource = self;
            self.search_display_controller.searchResultsDelegate = self;
            self.search_bar.scopeButtonTitles = nil;
            
            self.search_bar_cell = cell;
            return cell;
        }
        else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clear_cell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clear_cell"];
            }
            return cell;        
        }
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"content_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"content_cell"];
        }
        UILabel *option = (UILabel *)[cell viewWithTag:1];
        NSArray *values =[[[self.index_data objectForKey:@"sections"] objectAtIndex:indexPath.section - 1] objectForKey:@"values"]; 
        
        NSMutableDictionary *building = [values objectAtIndex:indexPath.row];
        
        if ([[building objectForKey:@"checked"] intValue] > 0) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        option.text = [building objectForKey:@"title"];
        
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
    if ([title isEqualToString:@"#"]) {
        return 0;
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

@end
