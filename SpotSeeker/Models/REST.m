//
//  REST.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "REST.h"
#import "GAI.h"

@implementation REST

@synthesize delegate;

-(void) getURLWithNoAccessToken:(NSString *)url {
    [self getURL:url withAccessToken:FALSE];
}

-(void) getURL:(NSString *)url {
    [self getURL:url withAccessToken:TRUE];
}

-(void)getURL:(NSString *)url withAccessToken:(Boolean)use_token {
    [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
    NSString *request_url = [self _getFullURL:url];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:request_url]];
    
    [self _signRequest:request withAccessToken:use_token];
    
    [request setDelegate:self];
    [request startAsynchronous];
    [[GAI sharedInstance] dispatch];

}

-(void)deleteURL:(NSString *)url {
    [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
    NSString *request_url = [self _getFullURL:url];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:request_url]];
    [request setRequestMethod:@"DELETE"];
    
    [self _signRequest:request withAccessToken:true];
    
    [request setDelegate:self];
    [request startAsynchronous];
    [[GAI sharedInstance] dispatch];
    
}

-(void)putURL:(NSString *)url withBody:(NSString *)body {
    [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
    NSString *request_url = [self _getFullURL:url];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:request_url]];
    [request setRequestMethod:@"PUT"];
    [request appendPostData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self _signRequest:request withAccessToken:true];
    
    [request setDelegate:self];
    [request startAsynchronous];
    [[GAI sharedInstance] dispatch];
    
}


-(void)OAuthTokenRequestFromToken:(NSString *)token secret:(NSString *)token_secret andVerifier:(NSString *)verifier {
    [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
    NSString *request_url = [self _getFullURL:@"/oauth/access_token/"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:request_url]];
    [request setRequestMethod:@"POST"];


    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"spotseeker.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
    
    BOOL use_oauth = [[plist_values objectForKey:@"use_oauth"] boolValue];
    if (use_oauth) {
        NSString *oauth_key = [plist_values objectForKey:@"oauth_key"];
        NSString *oauth_secret = [plist_values objectForKey:@"oauth_secret"];
        
        [request signRequestWithClientIdentifier:oauth_key secret:oauth_secret
                                 tokenIdentifier:token secret:token_secret verifier:verifier
                                     usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];
    }

    [request setDelegate:self];
    [request startAsynchronous];
    [[GAI sharedInstance] dispatch];
    
}


-(ASIHTTPRequest *)getRequestForBlocksWithURL:(NSString *)url {
    NSString *request_url = [self _getFullURL:url];
    @autoreleasepool {
        __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:request_url]];

        [self _signRequest:request withAccessToken:TRUE];

        return request;
    }
}

-(void)_signRequest:(ASIHTTPRequest *)request withAccessToken:(Boolean)use_token {
    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"spotseeker.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
    
    BOOL use_oauth = [[plist_values objectForKey:@"use_oauth"] boolValue];
    if (use_oauth) {
        NSString *access_token = nil;
        NSString *access_token_secret = nil;
        
        NSString *oauth_key = [plist_values objectForKey:@"oauth_key"];
        NSString *oauth_secret = [plist_values objectForKey:@"oauth_secret"];

        if (use_token) {
            KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"spacescout" accessGroup:nil];

            access_token = [wrapper objectForKey:(__bridge id)kSecAttrAccount];
            access_token_secret = [wrapper objectForKey:(__bridge id)kSecValueData];
        }
        
        [request signRequestWithClientIdentifier:oauth_key secret:oauth_secret
                                 tokenIdentifier:access_token secret:access_token_secret
                                     usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];
    }
    

}

+(BOOL)hasPersonalOAuthToken {
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"spacescout" accessGroup:nil];
    
    NSString *access_token = [wrapper objectForKey:(__bridge id)kSecAttrAccount];
    NSString *access_token_secret = [wrapper objectForKey:(__bridge id)kSecValueData];

    if (![access_token  isEqual: @""] && ![access_token_secret  isEqual: @""]) {
        return TRUE;
    }
    return FALSE;
}

+(void)setPersonalOAuthToken:(NSString *)token andSecret:(NSString *)secret {
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"spacescout" accessGroup:nil];
    [wrapper setObject:token forKey:(__bridge id)kSecAttrAccount];
    [wrapper setObject:secret forKey:(__bridge id)kSecValueData];
}

+(void)removePersonalOAuthToken {
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"spacescout" accessGroup:nil];
    [wrapper resetKeychainItem];
}

-(NSString *)getFullURL:(NSString *)url {
    return [self _getFullURL:url];
}

-(NSString *)_getFullURL:(NSString *)url {
    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"spotseeker.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
    
    NSString *server = [plist_values objectForKey:@"spotseeker_host"];
    
    if (server == NULL) {
        NSLog(@"You need to copy the example_spotseeker.plist file to spotseeker.plist, and provide a spotseeker_host value");
    }
    
    server = [server stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    NSString *request_url = [server stringByAppendingString:url];

    return request_url;
}

-(void)requestFailed:(ASIHTTPRequest *)request {
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app_delegate showNoNetworkAlert];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [self.delegate requestFromREST:request];
}

@end
