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
            
            NSArray *keys = [[NSArray alloc] initWithObjects:@"title", @"screen_title", @"screen_header", @"screen_subheader", @"search_key", @"table_row_type", @"default_search_value", @"is_selected", @"default_selection_label", @"no_selection_label", @"show_chooser_label", @"clear_selections_label", @"value_label_title", nil];
            for (NSString *key in keys) {
                NSString *value = [filter objectForKey:key];
                if (value != nil) {
                    [filter_obj setObject:value forKey:key];
                }
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
                
                if ([option objectForKey:@"subtitle"]) {
                    [filter_option setObject:[option objectForKey:@"subtitle"] forKey:@"subtitle"];
                }
                
                if ([option objectForKey:@"clear_all"]) {
                    [filter_option setObject:[option objectForKey:@"clear_all"] forKey:@"clear_all"];
                }
                if ([option objectForKey:@"selected"]) {
                    [filter_option setObject:[NSNumber numberWithBool:TRUE] forKey:@"selected"];
                }
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
