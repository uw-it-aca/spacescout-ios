//
//  ReviewSpaceViewController.h
//  SpaceScout
//
//  Created by pmichaud on 4/1/14.
//
//

#import "ViewController.h"
#import "OAuthLoginViewController.h"
#import "REST.h"
#import "Space.h"
#import "OverlayMessage.h"

@interface ReviewSpaceViewController : UIViewController <OAuthLogin, UITextViewDelegate, RESTFinished> {
    
}

-(IBAction)selectRating:(id)sender;
-(IBAction)submitReview:(id)sender;
@property (nonatomic) BOOL handling_login;
@property (nonatomic, retain) Space *space;
@property (nonatomic) NSInteger rating;
@property (nonatomic, retain) REST *rest;
@property (nonatomic, retain) OverlayMessage *overlay;

@end
