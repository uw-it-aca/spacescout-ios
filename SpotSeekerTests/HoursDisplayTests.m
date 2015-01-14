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
    XCTAssertEqual([values count], (NSUInteger)0, @"No values");
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
    XCTAssertEqual([values count], (NSUInteger)0, @"No values");

}

// Outcome M alone, T alone, W, Th, F grouped.
// SPOT-234
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
    XCTAssertEqual([values count], (NSUInteger)3, @"3 lines to display");

    XCTAssertEqualObjects([values objectAtIndex:0], @"M: 11AM-3PM", @"Proper display for m");
    XCTAssertEqualObjects([values objectAtIndex:1], @"T: 11AM-2PM", @"Proper display for t");
    XCTAssertEqualObjects([values objectAtIndex:2], @"W-F: 11AM-3PM", @"Proper display for w,th,f");
    
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
    XCTAssertEqual([values count], (NSUInteger)1, @"1 line of display");
    
    XCTAssertEqualObjects([values objectAtIndex:0], @"M-F: 11AM-3PM", @"Proper M-F grouping");
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
    XCTAssertEqual([values count], (NSUInteger)3, @"3 lines to display");
    
    XCTAssertEqualObjects([values objectAtIndex:0], @"M,T: 11AM-3PM", @"Proper non-extra grouping");
    XCTAssertEqualObjects([values objectAtIndex:1], @"W: 11AM-3PM, 4PM-8:30PM", @"Proper bonus window day");
    XCTAssertEqualObjects([values objectAtIndex:2], @"Th,F: 11AM-3PM", @"Proper non-extra grouping");
    
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
    XCTAssertEqual([values count], (NSUInteger)1U, @"1 line to display");
    XCTAssertEqualObjects([values objectAtIndex:0], @"Daily: Open 24 hours", @"24 hours");    
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
    XCTAssertEqual([values count], (NSUInteger)3, @"3 lines to display");
    XCTAssertEqualObjects([values objectAtIndex:0], @"M: 8AM-midnight", @"Monday opener format");    
    XCTAssertEqualObjects([values objectAtIndex:1], @"T-Th: Open 24 hours", @"Mid-week 24 hours");    
    XCTAssertEqualObjects([values objectAtIndex:2], @"F: Open 24 hours, until 2AM", @"Friday finisher");    
}

-(void)testOverMidnight {
    NSMutableArray *monday = [[NSMutableArray alloc] init];
    NSMutableArray *tuesday = [[NSMutableArray alloc] init];
    NSMutableArray *wednesday = [[NSMutableArray alloc] init];
    NSMutableArray *thursday = [[NSMutableArray alloc] init];
    NSMutableArray *friday = [[NSMutableArray alloc] init];
    NSMutableArray *saturday = [[NSMutableArray alloc] init];
    NSMutableArray *sunday = [[NSMutableArray alloc] init];

    NSMutableArray *evening_part = [[NSMutableArray alloc] init];
    NSDateComponents *eve_start = [[NSDateComponents alloc] init];
    eve_start.hour = 8;
    eve_start.minute = 0;
    
    NSDateComponents *eve_end = [[NSDateComponents alloc] init];
    eve_end.hour = 23;
    eve_end.minute = 59;
    
    [evening_part addObject:eve_start];
    [evening_part addObject:eve_end];

    NSMutableArray *morning_part = [[NSMutableArray alloc] init];
    NSDateComponents *morn_start = [[NSDateComponents alloc] init];
    morn_start.hour = 0;
    morn_start.minute = 0;
    
    NSDateComponents *morn_end = [[NSDateComponents alloc] init];
    morn_end.hour = 3;
    morn_end.minute = 0;
    
    [morning_part addObject:morn_start];
    [morning_part addObject:morn_end];

    [tuesday addObject:evening_part];
    [wednesday addObject:morning_part];
    [wednesday addObject:evening_part];
    [thursday addObject:morning_part];
    [thursday addObject:evening_part];
    [friday addObject:morning_part];

    
    NSMutableDictionary *with_days = [[NSMutableDictionary alloc] init];
    [with_days setObject:monday forKey:@"monday"];
    [with_days setObject:tuesday forKey:@"tuesday"];
    [with_days setObject:wednesday forKey:@"wednesday"];
    [with_days setObject:thursday forKey:@"thursday"];
    [with_days setObject:friday forKey:@"friday"];
    [with_days setObject:saturday forKey:@"saturday"];
    [with_days setObject:sunday forKey:@"sunday"];
    
    
    NSMutableArray *values = [[HoursFormat alloc] displayLabelsForHours:with_days];
    XCTAssertEqual([values count], (NSUInteger)1, @"1 line1 to display");
    XCTAssertEqualObjects([values objectAtIndex:0], @"T-Th: 8AM-3AM", @"Over midnight format");    

    
}

@end
