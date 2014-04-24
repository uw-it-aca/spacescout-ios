//
//  OAuthLoginViewController.h
//  SpaceScout
//
//  Created by Patrick Michaud on 10/9/13.
//
//

#import "ViewController.h"
#import <Security/Security.h>
#import "KeychainItemWrapper.h"
#import "SBJson.h"
#import "REST.h"

@protocol OAuthLogin;

@interface OAuthLoginViewController : ViewController <RESTFinished> {
    REST *rest;
    IBOutlet UIWebView *auth_web_view;
    NSString *oauth_token;
    NSString *oauth_token_secret;
    id <OAuthLogin> delegate;
}

@property (nonatomic, retain) id <OAuthLogin> delegate;
@property (nonatomic, retain) NSString *oauth_token;
@property (nonatomic, retain) NSString *oauth_token_secret;
@property (nonatomic, retain) REST *rest;
@property (nonatomic, retain ) IBOutlet UIWebView *auth_web_view;


@end

@protocol OAuthLogin <NSObject>;

-(void) loginComplete;
-(void) loginCancelled;
-(IBAction)backButtonPressed:(id)sender;

@end
