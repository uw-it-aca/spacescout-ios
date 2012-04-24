//
//  REST.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "REST.h"

@implementation REST

@synthesize delegate;

-(void) getURL:(NSString *)url {
    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"spotseeker.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
    
    NSString *server = [plist_values objectForKey:@"spotseeker_host"];
    
    if (server == NULL) {
        NSLog(@"You need to copy the example_spotseeker.plist file to spotseeker.plist, and provide a spotseeker_host value");
    }
    
    server = [server stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    NSString *request_url = [server stringByAppendingString:url];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:request_url]];
        
    BOOL use_oauth = [[plist_values objectForKey:@"use_oauth"] boolValue];
    if (use_oauth) {
        NSString *oauth_key = [plist_values objectForKey:@"oauth_key"];
        NSString *oauth_secret = [plist_values objectForKey:@"oauth_secret"];
        [request signRequestWithClientIdentifier:oauth_key secret:oauth_secret
                                 tokenIdentifier:nil secret:nil
                                     usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];
    }
    
    [request setDelegate:self];
    [request startAsynchronous];

}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [self.delegate requestFromREST:request];
}

@end
