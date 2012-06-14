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
@synthesize page_header;
@synthesize page_footer;
@synthesize prev_button;
@synthesize next_button;

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
    int count = [self.spot.image_urls count];

    if (index == 0) {
        [self.prev_button setEnabled:FALSE];
    }
    else {
        [self.prev_button setEnabled:TRUE];        
    }
    
    if (index == count - 1) {
        [self.next_button setEnabled:FALSE];
    }
    else {
        [self.next_button setEnabled:TRUE];
    }
    
    UILabel *title = (UILabel *)[self.page_header viewWithTag:1];
    title.text = [NSString stringWithFormat:@"%i of %i", index+1, count];
    
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

-(void)showNextImage {
    self.current_index = [NSNumber numberWithInt:[self.current_index intValue] + 1];
    [self showCurrentImage];    
}

-(void)showPreviousImage {
    self.current_index = [NSNumber numberWithInt:[self.current_index intValue] - 1];
    [self showCurrentImage];
}

#pragma mark -
#pragma mark gesture methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.page_header]) {
        return NO;
    }
    if ([touch.view isDescendantOfView:self.page_footer]) {
        return NO;
    }

    return YES;
}

-(IBAction)swipeLeft:(id)sender {
    [self hideScreenNavigation];
    if ([self.current_index intValue] < [spot.image_urls count] - 1) {
        [self showNextImage];
    }

}

-(IBAction)swipeRight:(id)sender {
    [self hideScreenNavigation];
    if ([self.current_index intValue] > 0) {
        [self showPreviousImage];
    }

}

-(IBAction)screenTap:(id)sender {
    [self showScreenNavigation];
}

#pragma mark -
#pragma mark button actions

-(IBAction)closeGallery:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)clickNextImgBtn:(id)sender {
    [self showNextImage];
}

-(IBAction)clickPrevImgBtn:(id)sender {
    [self showPreviousImage];
}

#pragma mark -
#pragma mark navigation display handling

-(void) showScreenNavigation {
    page_header.hidden = NO;
    page_footer.hidden = NO;
}

-(void)hideScreenNavigation {
    page_header.hidden = YES;
    page_footer.hidden = YES;
}

@end
