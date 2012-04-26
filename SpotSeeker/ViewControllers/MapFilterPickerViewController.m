//
//  MapFilterPickerViewController.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapFilterPickerViewController.h"

@implementation MapFilterPickerViewController

@synthesize filter_picker;
@synthesize filter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[self.filter objectForKey:@"options"] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[[self.filter objectForKey:@"options"] objectAtIndex:row] objectForKey:@"title"];
} 

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.filter setObject:[[NSNumber alloc] initWithInteger:row] forKey:@"selected_row"];
}

- (void) viewDidAppear:(BOOL)animated {

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    	// Do any additional setup after loading the view.
    [self.filter_picker reloadAllComponents];
    NSInteger current_row = [[self.filter objectForKey:@"selected_row"]  integerValue];
    if (!current_row) {
        current_row = 0;
    }
    
    [self.filter_picker selectRow:current_row inComponent:0 animated:FALSE];

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

@end
