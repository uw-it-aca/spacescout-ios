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
@synthesize pan_recognizer;
@synthesize pinch_recognizer;
@synthesize tap_recognizer;
@synthesize image_data;
@synthesize page_header;
@synthesize page_footer;
@synthesize prev_button;
@synthesize next_button;
@synthesize pan_translation;
@synthesize activity_indicator;

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
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
    [self.view addGestureRecognizer:self.pinch_recognizer];
    [self.view addGestureRecognizer:self.pan_recognizer];
    [self.view addGestureRecognizer:self.tap_recognizer];
    [self recenterImageView];
    
    [self showCurrentImage];
	// Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self showScreenNavigation];    
    return YES;
}

#pragma mark -
#pragma mark image methods

-(void)showCurrentImage {
   
    image_view.image = nil;
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
        self.image_view.hidden = TRUE;
        self.activity_indicator.hidden = FALSE;
        
        __weak ASIHTTPRequest *request = [rest getRequestForBlocksWithURL:image_url];
        
        [request setCompletionBlock:^{
            [self.image_data insertObject:[request responseData] atIndex:index];
            if (index == [self.current_index intValue]) {
                [self showImageWithData:[request responseData]];
                
                self.activity_indicator.hidden = TRUE;
                self.image_view.hidden = FALSE;
            }
        }];
        
        [request startAsynchronous];
    }
}

-(void)requestFromREST:(ASIHTTPRequest *)request {
    if ([request responseStatusCode] == 200) {
        [self.image_data insertObject:[request responseData] atIndex:[self.current_index intValue]];
        [self showImageWithData:[request responseData]];
        
        self.activity_indicator.hidden = TRUE;
        self.image_view.hidden = FALSE;
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

-(void)recenterImageView {
    image_view.frame = CGRectMake(0, 0, image_view.frame.size.width, image_view.frame.size.height);
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


-(IBAction)handlePinch:(UIPinchGestureRecognizer *)gesture {
    /*
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        NSLog(@"Pinching start");
    }
    else if ([gesture state] == UIGestureRecognizerStateChanged ) {
        NSLog(@"In process - %f", [gesture scale]);
    }
    else if ([gesture state] == UIGestureRecognizerStateEnded) {
        NSLog(@"Done");
    }
     */
}


-(IBAction)handlePan:(UIPanGestureRecognizer *)gesture {
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        self.pan_translation = [NSNumber numberWithFloat:0.0];
        [self hideScreenNavigation];
    }
    if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:[image_view superview]];

        self.pan_translation = [NSNumber numberWithFloat:[self.pan_translation floatValue] + translation.x];
        [image_view setCenter:CGPointMake([image_view center].x + translation.x, [image_view center].y)];
        [gesture setTranslation:CGPointZero inView:[image_view superview]];
    }
    else {        
        // Doing this instead of a swipe, to make it look smoother
        if (([self.pan_translation floatValue] > self.view.frame.size.width / 4) && ([self.current_index intValue] > 0)) {
            [self recenterImageView];

            [self hideScreenNavigation];
            [self showPreviousImage];
        }
        else if (([self.pan_translation floatValue] < -1 * self.view.frame.size.width / 4) && ([self.current_index intValue] < [self.spot.image_urls count]-1)) 
        {
            [self recenterImageView];
            [self hideScreenNavigation];
            [self showNextImage];
        }
        else {
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options:UIViewAnimationCurveEaseOut
                             animations:^{   
                                 [self recenterImageView];
                             }
                             completion:^(BOOL finished) {
                             }
             ];
        }
    }
}


-(IBAction)screenTap:(id)sender {
    [self showScreenNavigation];
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UISwipeGestureRecognizer *)otherGestureRecognizer
{
    return YES;
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
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    page_header.hidden = NO;
    page_footer.hidden = NO;
}

-(void)hideScreenNavigation {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    page_header.hidden = YES;
    page_footer.hidden = YES;

}

@end
