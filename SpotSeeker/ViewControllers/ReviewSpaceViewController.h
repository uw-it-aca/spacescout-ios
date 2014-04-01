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

@interface ReviewSpaceViewController : ViewController <OAuthLogin> {
    
}

@property (nonatomic) BOOL handling_login;

@end
