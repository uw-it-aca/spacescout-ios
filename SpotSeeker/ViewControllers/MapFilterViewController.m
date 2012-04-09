//
//  MapFilterViewController.m
//  SpotSeeker
//
//  Copyright 2012 UW Information Technology, University of Washington
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MapFilterViewController.h"


@implementation MapFilterViewController

@synthesize spot;
@synthesize scroll_view;
@synthesize filter_view;
@synthesize basic_filter;
@synthesize access_filter;
@synthesize extras_filter;
@synthesize current_filter;
@synthesize filter_control;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)btnClickCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)btnClickSearch:(id)sender {
    NSDictionary *attributes = [NSDictionary alloc];
  
    Spot *_spot = [Spot alloc];
    self.spot = _spot;
    [self.spot getListBySearch:attributes];
    [self.spot setDelegate:self];
}

-(IBAction)btnClickChangeFilter:(id)sender {
    switch (self.filter_control.selectedSegmentIndex) {
        case 0:
            [self showFilterView:self.basic_filter]; 
            break;
        case 1:
            [self showFilterView:self.access_filter]; 
            break;
        case 2:
            [self showFilterView:self.extras_filter]; 
            break;
    }
}

-(void) searchFinished:(NSArray *)spots {
    [self dismissModalViewControllerAnimated:YES]; 
}

-(void) showFilterView:(UIView *)view {
    if (self.current_filter) {
        self.current_filter.hidden = TRUE;
    }

    self.current_filter = view;
    view.hidden = FALSE;

    [view setFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    
    [self.scroll_view setContentSize:view.frame.size];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.basic_filter.hidden = TRUE;
    self.access_filter.hidden = TRUE;
    self.extras_filter.hidden = TRUE;
    [self showFilterView: self.basic_filter];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


@end
