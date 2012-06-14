//
//  SpotImagesViewController.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "Spot.h"
#import "REST.h"

@interface SpotImagesViewController : ViewController <RESTFinished, UIGestureRecognizerDelegate> {
    Spot *spot;
    IBOutlet UIImageView *image_view;
    NSNumber *current_index;
    REST *rest;
    NSMutableArray *image_data;
}

-(IBAction) swipeLeft:(id)sender;
-(IBAction) swipeRight:(id)sender;
-(IBAction) screenTap:(id)sender;
-(IBAction) closeGallery:(id)sender;

@property (nonatomic, retain) Spot *spot;
@property (nonatomic, retain) IBOutlet UIImageView *image_view;
@property (nonatomic, retain) NSNumber *current_index;
@property (nonatomic, retain) REST *rest;
@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipe_left_recognizer;
@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipe_right_recognizer;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tap_recognizer;
@property (nonatomic, strong) IBOutlet UIView *page_header;

@property (nonatomic, retain) NSMutableArray *image_data;

@end
