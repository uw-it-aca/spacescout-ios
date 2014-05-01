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
    NSMutableArray *by_day_strings = [[NSMutableArray alloc] init];

    NSMutableArray *days = [[NSMutableArray alloc] initWithObjects:@"sunday", @"monday", @"tuesday", @"wednesday", @"thursday", @"friday", @"saturday", @"sunday", @"monday", nil];

    for (int index = 1; index <= 7; index++) {
        NSArray *todays_hours = [hours objectForKey:[days objectAtIndex:index]];
        NSArray *tomorrow_hours = [hours objectForKey:[days objectAtIndex:index + 1]];
        NSArray *yesterday_hours = [hours objectForKey:[days objectAtIndex:index - 1]];
        [by_day_strings addObject:[self getStringDescribingHours:todays_hours dayBefore:yesterday_hours nextDay:tomorrow_hours]];
    }
    NSMutableArray *display_strings = [[NSMutableArray alloc] init];

    NSArray *day_groups = [self groupDaysBySameHours:by_day_strings];
    for (NSDictionary *group in day_groups) {
        [display_strings addObject:[self getDisplayStringForGroup:group]];
    }
    
    return display_strings;
}

-(NSString *)getDisplayStringForGroup:(NSDictionary *)group {
    NSString *day_string = [self getStringDescribingDays:[group objectForKey:@"days"]];
    NSString *hours_string = [group objectForKey:@"hours"];
    return [NSString stringWithFormat:@"%@: %@", day_string, hours_string];
}

-(NSString *)getStringDescribingHours:(NSArray *)hours dayBefore:(NSArray *)prev_hours nextDay:(NSArray *)next_hours {
    NSMutableArray *display_parts =  [[NSMutableArray alloc] init];
    
//    bool yesterday_is_24_hours = [self isOpen24Hours:prev_hours];
    bool yesterday_ends_at_midnight = [self doesWindowEndAtMidnight:prev_hours];
    bool tomorrow_is_24_hours = [self isOpen24Hours:next_hours];
    bool tomorrow_starts_at_midnight = [self doesWindowStartAtMidnight:next_hours];
    
    for (NSArray *window in hours) {
        NSDateComponents *start_time = [window objectAtIndex:0];
        NSDateComponents *end_time = [window objectAtIndex:1];
        
        NSDateComponents *tomorrows_end_time  = [self getEndOfWindowStartingAtMidnight:next_hours];
        long int tomorrows_hour = tomorrows_end_time.hour;
        long int todays_end_hour = end_time.hour;

        if (start_time.hour == 0 && start_time.minute == 0 && end_time.hour == 23 && end_time.minute == 59 && tomorrow_starts_at_midnight && !tomorrow_is_24_hours && tomorrows_hour > 3) {
            [display_parts addObject:[NSString stringWithFormat: @"Open 24 hours"]];
        }

        else if (start_time.hour == 0 && start_time.minute == 0 && end_time.hour == 23 && end_time.minute == 59 && tomorrow_starts_at_midnight && !tomorrow_is_24_hours) {
            [display_parts addObject:[NSString stringWithFormat: @"Open 24 hours, until %@", [self formatTime:tomorrows_end_time]]];
        }
        else if (start_time.hour == 0 && start_time.minute == 0 && end_time.hour == 23 && end_time.minute == 59) {
            [display_parts addObject:@"Open 24 hours"];
        }
        else if (start_time.hour == 0 && start_time.minute == 0 && yesterday_ends_at_midnight && todays_end_hour > 3) {
            [display_parts addObject:[NSString stringWithFormat:@"Midnight to %@", [self formatTime:end_time]]];
        }
        else if (start_time.hour == 0 && start_time.minute == 0 && yesterday_ends_at_midnight) {
            // this is handled by the ", until %@" above
        }
        else if (end_time.hour == 23 && end_time.minute == 59 && tomorrow_starts_at_midnight && !tomorrow_is_24_hours) {
            NSString *window_display = [NSString stringWithFormat:@"%@-%@", [self formatTime: start_time], [self formatTime: tomorrows_end_time]];
            [display_parts addObject:window_display];
        }
        else {
            NSString *window_display = [NSString stringWithFormat:@"%@-%@", [self formatTime: start_time], [self formatTime: end_time]];
            [display_parts addObject:window_display];
        }
    }
    
    NSString *value = [display_parts componentsJoinedByString:@", "];
    return value;
}

-(bool)doesWindowEndAtMidnight:(NSArray *)windows {
    for (NSArray *window in windows) {
        NSDateComponents *end_time = [window objectAtIndex:1];
        if (end_time.hour == 23 && end_time.minute == 59) {
            return true;
        }
    }
    return false;
}
                                       
-(bool)doesWindowStartAtMidnight:(NSArray *)windows {
    for (NSArray *window in windows) {
        NSDateComponents *start_time = [window objectAtIndex:0];
        if (start_time.hour == 0 && start_time.minute == 0) {
            return true;
        }
    }
    return false;
}

-(NSDateComponents *)getEndOfWindowStartingAtMidnight:(NSArray *)windows {
    for (NSArray *window in windows) {
        NSDateComponents *start_time = [window objectAtIndex:0];
        if (start_time.hour == 0 && start_time.minute == 0) {
            return [window objectAtIndex:1];
        }
    }
    return nil;    
}
                                       
-(bool)isOpen24Hours:(NSArray *)windows {
    for (NSArray *window in windows) {
        NSDateComponents *start_time = [window objectAtIndex:0];
        NSDateComponents *end_time = [window objectAtIndex:1];
        if (start_time.hour == 0 && start_time.minute == 0 && end_time.hour == 23 && end_time.minute == 59) {
            return true;
        }
    }
    return false;
}


-(NSString *)formatTime:(NSDateComponents *)time {
    NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
    NSDate *time_as_date = [cal dateFromComponents:time];

    if (time.hour == 23 && time.minute == 59) {
        return @"midnight";
    }
    
    if (time.minute == 0) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"ha"];
        return [df stringFromDate:time_as_date];
    }
    else {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"h:mma"];
        return [df stringFromDate:time_as_date];        
    }
}

-(NSString *)getStringDescribingDays:(NSArray *)days {
    NSArray *display_days = [[NSArray alloc] initWithObjects:@"M", @"T", @"W", @"Th", @"F", @"S", @"Su", nil];

    NSMutableArray *selected_days = [[NSMutableArray alloc] init];
    for (int index = 0; index < 7; index++) {
        [selected_days addObject:[NSNumber numberWithBool:FALSE]];
    }
    
    NSMutableArray *display_parts = [[NSMutableArray alloc] init];
    for (NSString *day in days) {
        int index = 0;
        if ([day isEqualToString: @"monday"]) {
            index = 0;
        }
        else if ([day isEqualToString: @"tuesday"]) {
            index = 1;
        }
        else if ([day isEqualToString: @"wednesday"]) {
            index = 2;
        }
        else if ([day isEqualToString: @"thursday"]) {
            index = 3;
        }
        else if ([day isEqualToString: @"friday"]) {
            index = 4;
        }
        else if ([day isEqualToString: @"saturday"]) {
            index = 5;
        }
        else {
            index = 6;
        }
        [selected_days insertObject:[NSNumber numberWithBool:TRUE] atIndex:index];

    }
    
    NSMutableArray *selected_set = [[NSMutableArray alloc] init];
    for (int index = 0; index < 7; index++) {
        if ([[selected_days objectAtIndex:index] boolValue]) {
            [selected_set addObject:[display_days objectAtIndex:index]];
        }
        else {
            if ([selected_set count]) {
                [display_parts addObject:[self getDisplayStringForDayGroup:selected_set]];
                [selected_set removeAllObjects];
            }
        }
    }
    if ([selected_set count]) {
        [display_parts addObject:[self getDisplayStringForDayGroup:selected_set]];
    }
    
    return [display_parts componentsJoinedByString:@","];
}

-(NSString *)getDisplayStringForDayGroup:(NSArray *)days {
    if ([days count] == 1) {
        return [days objectAtIndex:0];
    }
    else if ([days count] == 2) {
        return [days componentsJoinedByString:@","];
    }
    else if ([days count] == 7) {
        return @"Daily";
    }
    else {
        return [NSString stringWithFormat:@"%@-%@", [days objectAtIndex:0], [days objectAtIndex:[days count] - 1]];
    }
}

-(NSMutableArray *)groupDaysBySameHours:(NSArray *)display_hours {
    
    NSArray *day_names = [[NSArray alloc] initWithObjects:@"monday", @"tuesday", @"wednesday", @"thursday", @"friday", @"saturday", @"sunday", nil];
  
    NSString *previous_day_display = @"";
    NSMutableArray *groups = [[NSMutableArray alloc] init];
   
    // Grouping is easy now - if a day is not the same as the previous day, start a new group.
    for (int index = 0; index < 7; index++) {
        NSString *day_display = [display_hours objectAtIndex:index];
        
        if (![day_display isEqualToString:@""]) {
            if ([day_display isEqualToString:previous_day_display]) {
                NSMutableDictionary *last_group = [groups objectAtIndex:[groups count]-1];
                NSMutableArray *days = [last_group objectForKey:@"days"];
                [days addObject:[day_names objectAtIndex:index]];
            }
            else {
                NSMutableDictionary *new_group = [[NSMutableDictionary alloc] init];
                [new_group setObject:day_display forKey:@"hours"];
                NSMutableArray *days = [[NSMutableArray alloc] init];
                [days addObject:[day_names objectAtIndex:index]];
                [new_group setObject:days forKey:@"days"];
                [groups addObject:new_group];
            }
            previous_day_display = day_display;
        }
    }
    
    return groups;
}

@end
