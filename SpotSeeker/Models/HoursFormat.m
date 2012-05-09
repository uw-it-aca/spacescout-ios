//
//  HoursFormat.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HoursFormat.h"

@implementation HoursFormat

-(NSMutableArray *)displayLabelsForHours:(NSDictionary *)hours {
    NSMutableArray *display_strings = [[NSMutableArray alloc] init];
    
    NSArray *day_groups = [self groupDaysBySameHours:hours];
    for (NSDictionary *group in day_groups) {
        [display_strings addObject:[self getDisplayStringForGroup:group]];
    }
    
    return display_strings;
}

-(NSString *)getDisplayStringForGroup:(NSDictionary *)group {
    return @"";
}

-(NSMutableArray *)groupDaysBySameHours:(NSDictionary *)hours {
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    for (NSString *day in [[NSArray alloc] initWithObjects:@"monday", @"tuesday", @"wednesday", @"thursday", @"friday", @"saturday", @"sunday", nil]) {
        NSArray *day_windows = [hours objectForKey:day];
        if ([day_windows count] == 0) {
            continue;
        }
        
        BOOL found_group = false;
        for (NSDictionary *group in groups) {
            NSArray *group_windows = [group objectForKey:@"hours"];
            if ([group_windows count] == [day_windows count] && !found_group) {
                for (int index = 0; index < [group_windows count]; index++) {
                    NSArray *group_window = [group_windows objectAtIndex:index];
                    NSArray *day_window   = [day_windows objectAtIndex:index];
                    
                    NSDateComponents *group_start = [group_window objectAtIndex:0];
                    NSDateComponents *group_end = [group_window objectAtIndex:1];
                    NSDateComponents *day_start = [day_window objectAtIndex:0];
                    NSDateComponents *day_end = [day_window objectAtIndex:1];
                    
                    if ((group_start.hour == day_start.hour) && 
                        (group_end.hour == day_end.hour) && 
                        (group_start.minute == day_start.minute) && 
                        (group_end.minute == day_end.minute)) {
                        
                        found_group = true;
                        NSMutableArray *group_days = [group objectForKey:@"days"];
                        [group_days addObject:day];
                    }
                }
            }
        }
        
        if (!found_group) {
            NSMutableDictionary *new_group = [[NSMutableDictionary alloc] init];
            NSMutableArray *group_hours = [[NSMutableArray alloc] initWithArray:day_windows copyItems:true];
            NSMutableArray *group_days = [[NSMutableArray alloc] initWithObjects:day, nil];
            
            [new_group setObject:group_hours forKey:@"hours"];
            [new_group setObject:group_days forKey:@"days"];
            
            [groups addObject:new_group];
        }
    }
    
    NSLog(@"Returning groups: %@", groups);
    return groups;
}

@end
