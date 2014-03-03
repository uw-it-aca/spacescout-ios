//
//  OAuthLoginViewController.m
//  SpaceScout
//
//  Created by Patrick Michaud on 10/9/13.
//
//

#import "OAuthLoginViewController.h"

@interface OAuthLoginViewController ()

@end

@implementation OAuthLoginViewController

@synthesize oauth_token;
@synthesize oauth_token_secret;
@synthesize rest;
@synthesize auth_web_view;

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
    REST *_rest = [[REST alloc] init];
    _rest.delegate = self;

    // If there's an existing access token, this url gives a 401.
    [_rest getURLWithNoAccessToken:@"/oauth/request_token/?oauth_callback=oob"];
    self.rest = _rest;

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)requestFromREST:(ASIHTTPRequest *)request {
    
    NSString *url = [[request url] absoluteString];
    
    if ([url rangeOfString:@"request_token"].length > 0) {
        if (200 != [request responseStatusCode]) {
            NSLog(@"Code: %i", [request responseStatusCode]);
            // show an error
        }

        NSString *token_data = [request responseString];
        
        NSDictionary *params = [self dictionaryFromParamsString:token_data];
        
        NSString *token = [params objectForKey:@"oauth_token"];
        NSString *token_secret = [params objectForKey:@"oauth_token_secret"];

        self.oauth_token = token;
        self.oauth_token_secret = token_secret;

        NSString *partial_url = [NSString stringWithFormat:@"/oauth/authorize/?oauth_token=%@", token];
        NSString *url = [self.rest getFullURL:partial_url];
        NSURLRequest *auth_request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.auth_web_view loadRequest:auth_request];
    }
    else {
        
        NSDictionary *params = [self dictionaryFromParamsString:[request responseString]];
        
        [REST setPersonalOAuthToken:[params objectForKey:@"oauth_token"] andSecret:[params objectForKey:@"oauth_token_secret"]];
        [self.delegate loginComplete];
        
        [self dismissViewControllerAnimated:TRUE completion:^(void) {}];
    }
}

-(IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:^(void) {
        [self.delegate loginCancelled];
    }];
}

-(NSDictionary *)dictionaryFromParamsString:(NSString *)params {
    NSArray *token_sets = [params componentsSeparatedByString:@"&"];
    NSMutableDictionary *lookup = [[NSMutableDictionary alloc] init];
    
    for (NSString *token in token_sets) {
        NSArray *split = [token componentsSeparatedByString:@"="];
        [lookup setObject:split[1] forKey:split[0]];
    }

    return lookup;
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
    
    NSString *js = @"var el = document.getElementById('verification'); if (el) { el.textContent; } else { null; }";
    NSString *verifier = [self.auth_web_view stringByEvaluatingJavaScriptFromString:js];
    
    if ([verifier length] == 0) {
        return;
    }
    
    wv.hidden = TRUE;
    NSMutableDictionary *token_params = [[NSMutableDictionary alloc] init];
    [token_params setObject:verifier forKey:@"oauth_verifier"];
    [token_params setObject:self.oauth_token forKey:@"oauth_token"];\
    
    [self.rest OAuthTokenRequestFromToken:self.oauth_token secret:self.oauth_token_secret andVerifier:verifier];
}

@end
