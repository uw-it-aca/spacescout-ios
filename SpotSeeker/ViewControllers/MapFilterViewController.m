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
@synthesize scroll_view;
@synthesize filter_view;
@synthesize filter_table;
@synthesize data_sections;
@synthesize current_section;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)btnClickCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)btnClickSearch:(id)sender {
    NSDictionary *attributes = [NSDictionary alloc];
  
    Spot *_spot = [Spot alloc];
    self.spot = _spot;
    [self.spot getListBySearch:attributes];
    [self.spot setDelegate:self];
}


-(void) searchFinished:(NSArray *)spots {
    [self dismissModalViewControllerAnimated:YES]; 
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
    static NSString *CellIdentifier = @"generic_cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
        
    NSMutableDictionary *current_obj = [[[self.data_sections objectAtIndex:indexPath.section] objectForKey:@"filters"] objectAtIndex:indexPath.row];
    
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

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    self.current_section = [[[self.data_sections objectAtIndex:indexPath.section] objectForKey:@"filters"] objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"filter_options" sender:self];
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
            [filter_obj setObject:[filter objectForKey:@"default_selection_label"] forKey:@"default_selection_label"];
            
            NSMutableArray *filter_options = [[NSMutableArray alloc] init ];
            NSArray *options = [filter objectForKey:@"options"];
            for (NSDictionary *option in options) {
                NSMutableDictionary *filter_option = [[NSMutableDictionary alloc] init];
                [filter_option setObject:[option objectForKey:@"title"] forKey:@"title"];
                [filter_option setObject:[option objectForKey:@"short"] forKey:@"short"];
                [filter_option setObject:[NSNumber numberWithBool:FALSE] forKey:@"selected"];                                      
                [filter_options addObject:filter_option];
            }
            
            [filter_obj setObject:filter_options forKey:@"options"];
            [filters addObject:filter_obj];

        }
        [filter_group setObject:filters forKey:@"filters"];
        [groups addObject:filter_group];

   }
    

   self.data_sections = groups;

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


@end
