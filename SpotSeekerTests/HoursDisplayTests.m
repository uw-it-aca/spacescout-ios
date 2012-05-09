//
//  HoursDisplayTests.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HoursDisplayTests.h"

@implementation HoursDisplayTests

-(void)testEmptyHours {
    NSMutableArray *values = [[HoursFormat alloc] displayLabelsForHours:[[NSDictionary alloc] init]];
    STAssertEquals([values count], 0U, @"No values");
}

-(void)testEmptyHoursWithDays {
    NSMutableDictionary *with_days = [[NSMutableDictionary alloc] init];
    [with_days setObject:[[NSMutableArray alloc] init] forKey:@"monday"];
    [with_days setObject:[[NSMutableArray alloc] init] forKey:@"tuesday"];
    [with_days setObject:[[NSMutableArray alloc] init] forKey:@"wednesday"];
    [with_days setObject:[[NSMutableArray alloc] init] forKey:@"thursday"];
    [with_days setObject:[[NSMutableArray alloc] init] forKey:@"friday"];
    [with_days setObject:[[NSMutableArray alloc] init] forKey:@"saturday"];
    [with_days setObject:[[NSMutableArray alloc] init] forKey:@"sunday"];

    NSMutableArray *values = [[HoursFormat alloc] displayLabelsForHours:with_days];
    STAssertEquals([values count], 0U, @"No values");

}

// Outcome M, W, Th, F grouped, T not grouped.
-(void)testCommaDayGrouping {
    NSMutableArray *monday = [[NSMutableArray alloc] init];
    NSMutableArray *tuesday = [[NSMutableArray alloc] init];
    NSMutableArray *wednesday = [[NSMutableArray alloc] init];
    NSMutableArray *thursday = [[NSMutableArray alloc] init];
    NSMutableArray *friday = [[NSMutableArray alloc] init];
    NSMutableArray *saturday = [[NSMutableArray alloc] init];
    NSMutableArray *sunday = [[NSMutableArray alloc] init];
    
    NSMutableArray *m_w_th_f_window = [[NSMutableArray alloc] init];
    
   
    NSDateComponents *start_date = [[NSDateComponents alloc] init];
    start_date.hour = 11;
    start_date.minute = 0;
       
    NSDateComponents *end_date = [[NSDateComponents alloc] init];
    end_date.hour = 15;
    end_date.minute = 0;
    
    [m_w_th_f_window addObject:start_date];
    [m_w_th_f_window addObject:end_date];
    
    [monday addObject:m_w_th_f_window];
    [wednesday addObject:m_w_th_f_window];
    [thursday addObject:m_w_th_f_window];
    [friday addObject:m_w_th_f_window];

    NSMutableArray *tues_window = [[NSMutableArray alloc] init];
    NSDateComponents *tues_end = [[NSDateComponents alloc] init];
    tues_end.hour = 14;
    tues_end.minute = 0;
    
    [tues_window addObject:start_date];
    [tues_window addObject:tues_end];
    [tuesday addObject:tues_window];
    
    NSMutableDictionary *with_days = [[NSMutableDictionary alloc] init];
    [with_days setObject:monday forKey:@"monday"];
    [with_days setObject:tuesday forKey:@"tuesday"];
    [with_days setObject:wednesday forKey:@"wednesday"];
    [with_days setObject:thursday forKey:@"thursday"];
    [with_days setObject:friday forKey:@"friday"];
    [with_days setObject:saturday forKey:@"saturday"];
    [with_days setObject:sunday forKey:@"sunday"];
    
    
    NSMutableArray *values = [[HoursFormat alloc] displayLabelsForHours:with_days];
    STAssertEquals([values count], 2U, @"2 lines to display");

    STAssertEqualObjects([values objectAtIndex:0], @"M,W,Th,F: 11am-3pm", @"Proper display for m,w,th,f");
    STAssertEqualObjects([values objectAtIndex:1], @"T: 11am-2pm", @"Proper display for t");
    
}

// Outcome m-f
-(void)testDashedDays {
    NSMutableArray *monday = [[NSMutableArray alloc] init];
    NSMutableArray *tuesday = [[NSMutableArray alloc] init];
    NSMutableArray *wednesday = [[NSMutableArray alloc] init];
    NSMutableArray *thursday = [[NSMutableArray alloc] init];
    NSMutableArray *friday = [[NSMutableArray alloc] init];
    NSMutableArray *saturday = [[NSMutableArray alloc] init];
    NSMutableArray *sunday = [[NSMutableArray alloc] init];
    
    NSMutableArray *m_t_w_th_f_window = [[NSMutableArray alloc] init];
    
    
    NSDateComponents *start_date = [[NSDateComponents alloc] init];
    start_date.hour = 11;
    start_date.minute = 0;
    
    NSDateComponents *end_date = [[NSDateComponents alloc] init];
    end_date.hour = 15;
    end_date.minute = 0;
    
    [m_t_w_th_f_window addObject:start_date];
    [m_t_w_th_f_window addObject:end_date];
    
    [monday addObject:m_t_w_th_f_window];
    [tuesday addObject:m_t_w_th_f_window];
    [wednesday addObject:m_t_w_th_f_window];
    [thursday addObject:m_t_w_th_f_window];
    [friday addObject:m_t_w_th_f_window];
 
   
    NSMutableDictionary *with_days = [[NSMutableDictionary alloc] init];
    [with_days setObject:monday forKey:@"monday"];
    [with_days setObject:tuesday forKey:@"tuesday"];
    [with_days setObject:wednesday forKey:@"wednesday"];
    [with_days setObject:thursday forKey:@"thursday"];
    [with_days setObject:friday forKey:@"friday"];
    [with_days setObject:saturday forKey:@"saturday"];
    [with_days setObject:sunday forKey:@"sunday"];
    
    NSMutableArray *values = [[HoursFormat alloc] displayLabelsForHours:with_days];
    STAssertEquals([values count], 1U, @"1 line of display");
    
    STAssertEqualObjects([values objectAtIndex:0], @"M-F: 11am-3pm", @"Proper M-F grouping");
}


-(void)testOneDayExtraWindow {
    NSMutableArray *monday = [[NSMutableArray alloc] init];
    NSMutableArray *tuesday = [[NSMutableArray alloc] init];
    NSMutableArray *wednesday = [[NSMutableArray alloc] init];
    NSMutableArray *thursday = [[NSMutableArray alloc] init];
    NSMutableArray *friday = [[NSMutableArray alloc] init];
    NSMutableArray *saturday = [[NSMutableArray alloc] init];
    NSMutableArray *sunday = [[NSMutableArray alloc] init];
    
    NSMutableArray *m_t_w_th_f_window = [[NSMutableArray alloc] init];
    
    
    NSDateComponents *start_date = [[NSDateComponents alloc] init];
    start_date.hour = 11;
    start_date.minute = 0;
    
    NSDateComponents *end_date = [[NSDateComponents alloc] init];
    end_date.hour = 15;
    end_date.minute = 0;
    
    [m_t_w_th_f_window addObject:start_date];
    [m_t_w_th_f_window addObject:end_date];
    
    [monday addObject:m_t_w_th_f_window];
    [tuesday addObject:m_t_w_th_f_window];
    [wednesday addObject:m_t_w_th_f_window];
    [thursday addObject:m_t_w_th_f_window];
    [friday addObject:m_t_w_th_f_window];

    NSMutableArray *bonus_window = [[NSMutableArray alloc] init];

    NSDateComponents *bonus_start = [[NSDateComponents alloc] init];
    bonus_start.hour = 16;
    bonus_start.minute = 0;
    
    NSDateComponents *bonus_end = [[NSDateComponents alloc] init];
    bonus_end.hour = 20;
    bonus_end.minute = 30;
    
    [bonus_window addObject:bonus_start];
    [bonus_window addObject:bonus_end];

    [wednesday addObject:bonus_window];
    
    NSMutableDictionary *with_days = [[NSMutableDictionary alloc] init];
    [with_days setObject:monday forKey:@"monday"];
    [with_days setObject:tuesday forKey:@"tuesday"];
    [with_days setObject:wednesday forKey:@"wednesday"];
    [with_days setObject:thursday forKey:@"thursday"];
    [with_days setObject:friday forKey:@"friday"];
    [with_days setObject:saturday forKey:@"saturday"];
    [with_days setObject:sunday forKey:@"sunday"];
    
    NSMutableArray *values = [[HoursFormat alloc] displayLabelsForHours:with_days];
    STAssertEquals([values count], 2U, @"2 lines to display");
    
    STAssertEqualObjects([values objectAtIndex:0], @"M,T,Th,F: 11am-3pm", @"Proper non-extra grouping");
    STAssertEqualObjects([values objectAtIndex:0], @"W: 11am-3pm, 4pm-8:30pm", @"Proper bonus window day");
    
}

-(void)test24Hours {
    NSMutableArray *monday = [[NSMutableArray alloc] init];
    NSMutableArray *tuesday = [[NSMutableArray alloc] init];
    NSMutableArray *wednesday = [[NSMutableArray alloc] init];
    NSMutableArray *thursday = [[NSMutableArray alloc] init];
    NSMutableArray *friday = [[NSMutableArray alloc] init];
    NSMutableArray *saturday = [[NSMutableArray alloc] init];
    NSMutableArray *sunday = [[NSMutableArray alloc] init];
    
    NSMutableArray *window_24_hours = [[NSMutableArray alloc] init];
    
    NSDateComponents *start_date = [[NSDateComponents alloc] init];
    start_date.hour = 0;
    start_date.minute = 0;
    
    NSDateComponents *end_date = [[NSDateComponents alloc] init];
    end_date.hour = 23;
    end_date.minute = 59;
    
    [window_24_hours addObject:start_date];
    [window_24_hours addObject:end_date];
    
    [monday addObject:window_24_hours];
    [tuesday addObject:window_24_hours];
    [wednesday addObject:window_24_hours];
    [thursday addObject:window_24_hours];
    [friday addObject:window_24_hours];
    [saturday addObject:window_24_hours];
    [sunday addObject:window_24_hours];
    
    NSMutableDictionary *with_days = [[NSMutableDictionary alloc] init];
    [with_days setObject:monday forKey:@"monday"];
    [with_days setObject:tuesday forKey:@"tuesday"];
    [with_days setObject:wednesday forKey:@"wednesday"];
    [with_days setObject:thursday forKey:@"thursday"];
    [with_days setObject:friday forKey:@"friday"];
    [with_days setObject:saturday forKey:@"saturday"];
    [with_days setObject:sunday forKey:@"sunday"];

    NSMutableArray *values = [[HoursFormat alloc] displayLabelsForHours:with_days];
    STAssertEquals([values count], 1U, @"1 line to display");
    STAssertEqualObjects([values objectAtIndex:0], @"Daily: Open 24 hours", @"24 hours");    
}

-(void)testMidnight {
    NSMutableArray *monday = [[NSMutableArray alloc] init];
    NSMutableArray *tuesday = [[NSMutableArray alloc] init];
    NSMutableArray *wednesday = [[NSMutableArray alloc] init];
    NSMutableArray *thursday = [[NSMutableArray alloc] init];
    NSMutableArray *friday = [[NSMutableArray alloc] init];
    NSMutableArray *saturday = [[NSMutableArray alloc] init];
    NSMutableArray *sunday = [[NSMutableArray alloc] init];
    
    NSMutableArray *window_24_hours = [[NSMutableArray alloc] init];
    
    NSDateComponents *start_date = [[NSDateComponents alloc] init];
    start_date.hour = 0;
    start_date.minute = 0;
    
    NSDateComponents *end_date = [[NSDateComponents alloc] init];
    end_date.hour = 23;
    end_date.minute = 59;
    
    [window_24_hours addObject:start_date];
    [window_24_hours addObject:end_date];

    NSMutableArray *monday_opener = [[NSMutableArray alloc] init];
    NSDateComponents *mon_start = [[NSDateComponents alloc] init];
    mon_start.hour = 8;
    mon_start.minute = 0;
    
    NSDateComponents *mon_end = [[NSDateComponents alloc] init];
    mon_end.hour = 23;
    mon_end.minute = 59;
    
    [monday_opener addObject:mon_start];
    [monday_opener addObject:mon_end];
    [monday addObject:monday_opener];
    
    [tuesday addObject:window_24_hours];
    [wednesday addObject:window_24_hours];
    [thursday addObject:window_24_hours];
    [friday addObject:window_24_hours];
    
    NSMutableArray *saturday_finish = [[NSMutableArray alloc] init];
    NSDateComponents *sat_start = [[NSDateComponents alloc] init];
    sat_start.hour = 0;
    sat_start.minute = 0;
    
    NSDateComponents *sat_end = [[NSDateComponents alloc] init];
    sat_end.hour = 2;
    sat_end.minute = 0;
    
    [saturday_finish addObject:sat_start];
    [saturday_finish addObject:sat_end];
    [saturday addObject:saturday_finish];

    
    NSMutableDictionary *with_days = [[NSMutableDictionary alloc] init];
    [with_days setObject:monday forKey:@"monday"];
    [with_days setObject:tuesday forKey:@"tuesday"];
    [with_days setObject:wednesday forKey:@"wednesday"];
    [with_days setObject:thursday forKey:@"thursday"];
    [with_days setObject:friday forKey:@"friday"];
    [with_days setObject:saturday forKey:@"saturday"];
    [with_days setObject:sunday forKey:@"sunday"];
    
    NSMutableArray *values = [[HoursFormat alloc] displayLabelsForHours:with_days];
    STAssertEquals([values count], 3U, @"3 lines to display");
    STAssertEqualObjects([values objectAtIndex:0], @"M: 8am-midnight", @"Monday opener format");    
    STAssertEqualObjects([values objectAtIndex:1], @"T-F: Open 24 hours", @"Mid-week 24 hours");    
    STAssertEqualObjects([values objectAtIndex:2], @"F: Open until 2am", @"Friday finisher");    
}

@end
