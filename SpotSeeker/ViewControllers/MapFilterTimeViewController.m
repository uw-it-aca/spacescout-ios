//
//  MapFilterTimeViewController.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapFilterTimeViewController.h"


@implementation MapFilterTimeViewController

@synthesize time_picker;
@synthesize filter;
@synthesize start_time;
@synthesize end_time;
@synthesize current_widget;

-(IBAction)timeSelected:(id)sender {
//    [self.filter setObject:self.date_picker.date forKey:@"selected_date"];
}

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
    self.start_time = [self.filter objectForKey:@"open_at"];
    self.end_time = [self.filter objectForKey:@"open_until"];
    
    if (self.start_time != nil) {
        [self updateStartButtonWithDateComponents:self.start_time];
    }
    if (self.end_time != nil) {
        [self updateEndButtonWithDateComponents:self.end_time];
    }
    
	// Do any additional setup after loading the view.
    NSDate *selected_date = [self.filter objectForKey:@"selected_date"];
    if (selected_date != Nil) {
//        [self.date_picker setDate:selected_date];
    }
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

-(void)viewDidDisappear:(BOOL)animated {
    if (self.end_time != nil) {
        [self.filter setObject:self.end_time forKey:@"open_until"];    
    }
    if (self.start_time != nil) {
        [self.filter setObject:self.start_time forKey:@"open_at"];
    }
}

#pragma mark -
#pragma mark button handling

-(IBAction)cancelBtnClick:(id)sender {
    self.end_time = [self.filter objectForKey:@"open_until"];
    self.start_time = [self.filter objectForKey:@"open_at"];
    
    [self.navigationController popViewControllerAnimated:YES];

}

-(IBAction)startTimeBtnClick:(id)sender {
    NSDateComponents *start =  [self getStartTime];
    [self showPickerWidget];

    self.current_widget = [NSNumber numberWithInt:1];
    [self setPickerDateComponents:start];
}

-(IBAction)endTimeBtnClick:(id)sender {
    NSDateComponents *end = [self getEndTime];
    [self showPickerWidget];
    
    self.current_widget = [NSNumber numberWithInt:2];
    [self setPickerDateComponents:end];
}

-(IBAction)resetBtnClick:(id)sender {
    if ([self.current_widget intValue] == 1) {
        NSDateComponents *new = [self getDefaultStartTime];
        self.start_time = new;
        [self setPickerDateComponents:new];
        [self updateStartButtonWithDateComponents:new];
    }
    else {
        NSDateComponents *new = [self getDefaultEndTime];
        self.end_time = new;
        [self setPickerDateComponents:new];
        [self updateEndButtonWithDateComponents:new];        
    }
}

-(IBAction)doneBtnClick:(id)sender {
    [self hidePickerWidget];
}

#pragma mark -
#pragma mark animations

-(void)showPickerWidget {
    UIView *wrapper = [self.view viewWithTag:5];
    
    if (!wrapper.hidden) {
        return;
    }
    
    CGRect current = wrapper.frame;
    CGRect starting = CGRectMake(0, 480, current.size.width, current.size.height);
    CGRect ending = CGRectMake(0, 480 - 60 - current.size.height, current.size.width, current.size.height);
    
    [wrapper setFrame:starting];
    wrapper.hidden = false;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{   
                         wrapper.frame = ending;
                     }
                     completion:^(BOOL finished) {
                     }
     ];

}

-(void)hidePickerWidget {
    UIView *wrapper = [self.view viewWithTag:5];
    
    CGRect current = wrapper.frame;
    CGRect ending = CGRectMake(0, 480 + current.size.height, current.size.width , current.size.height);
    
    [UIView animateWithDuration:0.5
                          delay:0.2
                        options:UIViewAnimationCurveEaseIn
                     animations:^{   
                         wrapper.frame = ending;
                     }
                     completion:^(BOOL finished) {
                         wrapper.hidden = true;
                     }
     ];
    
}

#pragma mark -
#pragma mark update button display
     
-(void)updateStartButtonWithDateComponents:(NSDateComponents *)components {
    UIButton *start = (UIButton *)[self.view viewWithTag:2];
    NSString *title = [self stringForDateComponents:components];
    [start setTitle:title forState:UIControlStateNormal];
}

-(void)updateEndButtonWithDateComponents:(NSDateComponents *)components {
    UIButton *end = (UIButton *)[self.view viewWithTag:3];
    NSString *title = [self stringForDateComponents:components];
    [end setTitle:title forState:UIControlStateNormal];

}

-(NSString *)stringForDateComponents:(NSDateComponents *)components {
    int hour = components.hour;
    NSString *am_pm;
    
    if (hour >= 12) {
        am_pm = @"PM";
    }
    else {
        am_pm = @"AM";
    }
    
    if (hour > 12) {
        hour -= 12;
    }
    
    if (hour == 0) {
        hour = 12;
    }
    
    NSString *display = [NSString stringWithFormat:@"%@, %i:%02i %@", [self dayNameForIndex:components.weekday -1], hour, components.minute, am_pm];
    return display;
}

#pragma mark -
#pragma mark date math
     
-(NSDateComponents *)getStartTime {
    if (self.start_time) {
        return self.start_time;
    }
    
    return [self getDefaultStartTime];
}

-(NSDateComponents *)getDefaultStartTime {
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now = [NSDate date];
    
    NSDateComponents *components = [cal components:( INT_MAX ) fromDate:now];
    
    // Get the minutes in the 15 minute interval format
    components.minute = (components.minute / 15) * 15;
    
    return components;    
}

-(NSDateComponents *)getEndTime {
    if (self.end_time) {
        return self.end_time;
    }

    return [self getDefaultEndTime];
}

-(NSDateComponents *)getDefaultEndTime {
    NSDateComponents *start = [self getStartTime];
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *tmp_date = [cal dateFromComponents:start];
    NSDate *end_date = [tmp_date dateByAddingTimeInterval:60*60];
    NSDateComponents *components = [cal components:( INT_MAX ) fromDate:end_date];
    
    return components;    
}

-(void)setNewWeekDay:(NSInteger)weekday ForDateComponents:(NSDateComponents *)date_components {
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *the_days = [[NSDateComponents alloc] init];
    the_days.day = weekday + 7 - date_components.weekday;
    
    NSDate *tmp_date = [cal dateFromComponents:date_components];

    NSDate *right_day = [cal dateByAddingComponents:the_days toDate:tmp_date options:0];
    
    NSDateComponents *right_values = [cal components:(INT_MAX) fromDate:right_day];
    
    date_components.day = right_values.day;
    date_components.month = right_values.month;
    date_components.year = right_values.year;
    date_components.weekday = right_values.weekday;
}

#pragma mark -
#pragma mark setting the picker value
     
-(void) setPickerDateComponents:(NSDateComponents *)components {
    int is_pm = 0;
    int hour = components.hour;
        
    if (hour >= 12) {
        is_pm = 1;
    }
    if (hour > 12) {
        hour -= 12;
    }
    
    if (hour == 0) {
        hour = 12;
    }
    
    BOOL is_animated = YES;
    // Sunday is 1 in components.weekday, but 0 in our spinner.
    [self.time_picker selectRow:(components.weekday - 1) inComponent:0 animated:is_animated];
    [self.time_picker selectRow:(hour-1) inComponent:1 animated:is_animated];
    [self.time_picker selectRow:(components.minute / 15) inComponent:2 animated:is_animated];

    [self.time_picker selectRow:is_pm inComponent:3 animated:is_animated];
     
}
     
#pragma mark -
#pragma mark picker methods

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSDateComponents *initial;
    if ([self.current_widget intValue] == 1) {
        initial = [self getStartTime];        
    }
    else {
        initial = [self getEndTime];                
    }

    NSDateComponents *new = [initial copy];

    int hour;
    switch (component) {
        case 0:
            [self setNewWeekDay:(row + 1) ForDateComponents:new];
            break;
        case 1:
            hour = row;
            if (hour == 11) {
                hour = -1;
            }
            if ([pickerView selectedRowInComponent:3] == 1) {
                new.hour = hour + 13;
            }
            else {
                new.hour = hour + 1; 
            }
            break;
        case 2:
            new.minute = row * 15;
            break;
        case 3:
            hour = [pickerView selectedRowInComponent:1];
            if (hour == 11) {
                hour = -1;
            }

            if (row == 0) {
                new.hour = hour + 1;
            }
            else {
                new.hour = hour + 13;
            }
            break;
    }
    
    if ([self.current_widget intValue] == 1) {
        self.start_time = new;
        [self.filter setObject:new forKey:@"selected_start_time"];
        [self updateStartButtonWithDateComponents:new];
    }
    else {
        self.end_time = new;
        [self.filter setObject:new forKey:@"selected_end_time"];
        [self updateEndButtonWithDateComponents:new];
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 4;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return 7;
        case 1:
            return 12;
        case 2:
            return 4;
        case 3:
            return 2;
        default:
            return -1;
    }
}



-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return 140;
        case 1:
            return 45.0;
        case 2:
            return 45.0;
        default:
            return 60.0;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 3) {
        switch (row) {
            case 0:
                return @"AM";
            case 1:
                return @"PM";
        }
    }
    else if (component == 2) {
        return [NSString stringWithFormat:@"%02i", row * 15];
    }
    else if (component == 1) {
        return [NSString stringWithFormat:@"%i", row+1];
    }
    else {
        return [self dayNameForIndex:row];
    }
    
    return @"OK";
}

-(NSString *)dayNameForIndex:(NSInteger)weekday {
    NSArray *days = [NSArray arrayWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];
    return [days objectAtIndex:weekday];
}

@end
