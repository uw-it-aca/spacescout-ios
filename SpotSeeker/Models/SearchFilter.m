//
//  SearchFilter.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchFilter.h"

@implementation SearchFilter
@synthesize delegate;

-(void)loadSearchFilters {
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
            
            NSString *default_selection_label = [filter objectForKey:@"default_selection_label"];
            if (default_search_value != nil) {
                [filter_obj setObject:default_selection_label forKey:@"default_selection_label"];
            }
            
            // For the chooser type
            NSString *no_selection_label = [filter objectForKey:@"no_selection_label"];
            if (no_selection_label != nil) {
                [filter_obj setObject:no_selection_label forKey:@"no_selection_label"];
            }

            NSString *show_chooser_label = [filter objectForKey:@"show_chooser_label"];
            if (show_chooser_label != nil) {
                [filter_obj setObject:show_chooser_label forKey:@"show_chooser_label"];
            }

            
            NSNumber *default_selection_position = [filter objectForKey:@"default_selection_position"];
            if (default_selection_position != nil) {
                [filter_obj setObject:default_selection_position forKey:@"selected_row"];
            }
            
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
    
    [self.delegate availableFilters:groups];
}

@end
