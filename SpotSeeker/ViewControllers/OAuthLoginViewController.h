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
#import "REST.h"

@interface OAuthLoginViewController : ViewController <RESTFinished> {
    REST *rest;
    IBOutlet UIWebView *auth_web_view;
    NSString *oauth_token;
    NSString *oauth_token_secret;
}

@property (nonatomic, retain) NSString *oauth_token;
@property (nonatomic, retain) NSString *oauth_token_secret;
@property (nonatomic, retain) REST *rest;
@property (nonatomic, retain ) IBOutlet UIWebView *auth_web_view;

@end
