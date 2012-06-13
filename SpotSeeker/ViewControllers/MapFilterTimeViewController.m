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

#pragma mark -
#pragma mark button handling

-(IBAction)startTimeBtnClick:(id)sender {
    NSDateComponents *start =  [self getStartTime];

    [self setPickerDateComponents:start];
}

-(IBAction)endTimeBtnClick:(id)sender {
    NSDateComponents *end = [self getEndTime];
    [self setPickerDateComponents:end];
}

     
#pragma mark -
#pragma mark date math
     
-(NSDateComponents *)getStartTime {
    if (self.start_time) {
        return self.start_time;
    }
    
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
    
    NSDateComponents *start = [self getStartTime];
            
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDate *tmp_date = [cal dateFromComponents:start];
    NSDate *end_date = [tmp_date dateByAddingTimeInterval:60*60];
    
    NSDateComponents *components = [cal components:( INT_MAX ) fromDate:end_date];

    return components;
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
    
    BOOL is_animated = YES;
    // Sunday is 1 in components.weekday, Monday is 0 in our spinner.
    [self.time_picker selectRow:((components.weekday + 5) % 7) inComponent:0 animated:is_animated];
    [self.time_picker selectRow:(hour-1) inComponent:1 animated:is_animated];
    [self.time_picker selectRow:(components.minute / 15) inComponent:2 animated:is_animated];

    [self.time_picker selectRow:is_pm inComponent:3 animated:is_animated];
     
}
     
#pragma mark -
#pragma mark picker methods

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
        return [NSString stringWithFormat:@"%i", row * 15];
    }
    else if (component == 1) {
        return [NSString stringWithFormat:@"%i", row+1];
    }
    else {
        NSArray *days = [NSArray arrayWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday", nil];
        return [days objectAtIndex:row];
    }
    
    return @"OK";
}

@end
