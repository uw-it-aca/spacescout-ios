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
