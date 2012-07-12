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
        [filter_group setObject:[section objectForKey:@"section_name"] forKey:@"section_name"];

        
        NSMutableArray *filters = [[NSMutableArray alloc] init ];
        
        NSArray *filters_data = [section objectForKey:@"filters"];
        for (NSDictionary *filter in filters_data) {
            NSMutableDictionary *filter_obj = [[NSMutableDictionary alloc] init ];
            
            NSArray *keys = [[NSArray alloc] initWithObjects:@"title", @"screen_title", @"screen_header", @"screen_subheader", @"search_key", @"table_row_type", @"default_search_value", @"selected", @"default_selection_label", @"no_selection_label", @"show_chooser_label", @"clear_selections_label", @"value_label_title", @"data_source", nil];
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
                
                NSArray *opt_keys = [[NSArray alloc] initWithObjects:@"title", @"short", @"selected", @"search_key", @"search_value", @"subtitle", @"clear_all", nil];
                for (NSString *key in opt_keys) {
                    NSString *value = [option objectForKey:key];
                    if (value != nil) {
                        [filter_option setObject:value forKey:key];
                    }
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
