//
//  MapFilterTimeViewController.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapFilterTimeViewController.h"


@implementation MapFilterTimeViewController

@synthesize date_picker;
@synthesize filter;

-(IBAction)timeSelected:(id)sender {
    [self.filter setObject:self.date_picker.date forKey:@"selected_date"];
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
        [self.date_picker setDate:selected_date];
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

@end
