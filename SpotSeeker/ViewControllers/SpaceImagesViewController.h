//
//  SpotImagesViewController.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "Space.h"
#import "REST.h"

@interface SpaceImagesViewController : ViewController <RESTFinished, UIGestureRecognizerDelegate> {
    Space *spot;
    IBOutlet UIImageView *image_view;
    NSNumber *current_index;
    REST *rest;
    NSMutableArray *image_data;
}

-(IBAction) screenTap:(id)sender;
-(IBAction) handlePan:(UIPanGestureRecognizer *)gesture;
-(IBAction) handlePinch:(UIPinchGestureRecognizer *)gesture;
-(IBAction) closeGallery:(id)sender;
-(IBAction) clickNextImgBtn:(id)sender;
-(IBAction) clickPrevImgBtn:(id)sender;


@property (nonatomic, retain) Space *spot;
@property (nonatomic, retain) IBOutlet UIImageView *image_view;
@property (nonatomic, retain) NSNumber *current_index;
@property (nonatomic, retain) REST *rest;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tap_recognizer;
@property (nonatomic, strong) IBOutlet UIPinchGestureRecognizer *pinch_recognizer;
@property (nonatomic, strong) IBOutlet UIPanGestureRecognizer *pan_recognizer;
@property (nonatomic, strong) IBOutlet UIView *page_header;
@property (nonatomic, strong) IBOutlet UIView *page_footer;
@property (nonatomic, strong) IBOutlet UIButton *prev_button;
@property (nonatomic, strong) IBOutlet UIButton *next_button;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activity_indicator;
@property (nonatomic, retain) NSNumber *pan_translation;

@property (nonatomic, retain) NSMutableArray *image_data;

@end
