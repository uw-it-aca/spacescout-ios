//
//  SpotImagesViewController.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SpotImagesViewController.h"

@implementation SpotImagesViewController

@synthesize spot;
@synthesize image_view;
@synthesize current_index;
@synthesize rest;
@synthesize swipe_left_recognizer;
@synthesize swipe_right_recognizer;
@synthesize tap_recognizer;
@synthesize image_data;

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
    self.current_index = [NSNumber numberWithInt:0];
    self.image_data = [[NSMutableArray alloc] init];
    self.rest = [[REST alloc] init];
    self.rest.delegate = self;
    
    [self.view addGestureRecognizer:self.swipe_left_recognizer];
    [self.view addGestureRecognizer:self.swipe_right_recognizer];
    [self.view addGestureRecognizer:self.tap_recognizer];
    
    [self showCurrentImage];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark image methods

-(void)showCurrentImage {
    int index = [self.current_index intValue];
    
    if (index < [self.image_data count] && [self.image_data objectAtIndex:index] != nil) {
        [self showImageWithData:[self.image_data objectAtIndex:index]];
    }
    else {
        NSString *image_url = [spot.image_urls objectAtIndex:index];
        [rest getURL:image_url];
    }
}

-(void)requestFromREST:(ASIHTTPRequest *)request {
    if ([request responseStatusCode] == 200) {
        [self.image_data insertObject:[request responseData] atIndex:[self.current_index intValue]];
        [self showImageWithData:[request responseData]];
    }
}

-(void)showImageWithData:(NSData *)data {
    UIImage *img = [[UIImage alloc] initWithData:data];
    [image_view setImage:img];
    
}
     
#pragma mark -
#pragma mark gesture methods

-(IBAction)swipeLeft:(id)sender {
    [self hideScreenNavigation];
    if ([self.current_index intValue] < [spot.image_urls count] - 1) {
        self.current_index = [NSNumber numberWithInt:[self.current_index intValue] + 1];
        [self showCurrentImage];
    }

}

-(IBAction)swipeRight:(id)sender {
    [self hideScreenNavigation];
    if ([self.current_index intValue] > 0) {
        self.current_index = [NSNumber numberWithInt:[self.current_index intValue] - 1];
        [self showCurrentImage];
    }

}

-(IBAction)screenTap:(id)sender {
    [self showScreenNavigation];
}

#pragma mark -
#pragma mark navigation display handling

-(void) showScreenNavigation {
    self.navigationController.navigationBar.hidden = NO;
}

-(void)hideScreenNavigation {
    self.navigationController.navigationBar.hidden = YES;
}

@end
