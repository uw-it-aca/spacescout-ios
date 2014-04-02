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

@interface ReviewSpaceViewController : ViewController <OAuthLogin, UITextViewDelegate> {
    
}

-(IBAction)selectRating:(id)sender;
@property (nonatomic) BOOL handling_login;
@property (nonatomic, retain) Space *space;
@property (nonatomic) int rating;

@end
