//
//  REST.m
//  SpotSeeker
//
//  Copyright 2015 UW Information Technology, University of Washington
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//

#import "REST.h"
#import "GAI.h"

@implementation REST

@synthesize delegate;

-(void) getURLWithNoAccessToken:(NSString *)url {
    [self getURL:url withAccessToken:FALSE withCache:FALSE];
}

-(void) getURL:(NSString *)url {
    [self getURL:url withAccessToken:TRUE];
}

-(void)getURL:(NSString *)url withAccessToken:(Boolean)use_token {
    [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
    
    [self getURL:url withAccessToken:use_token withCache:TRUE];
}

-(void)getURL:(NSString *)url withAccessToken:(BOOL)use_token withCache:(BOOL)use_cache {
    SearchQueueManager *sharedSearchQueueManager = [SearchQueueManager sharedQueueManager];
    [[sharedSearchQueueManager searchQueue] cancelAllOperations];
    NSString *request_url = [self _getFullURL:url];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:request_url]];
    
    [self _signRequest:request withAccessToken:use_token];
    
    if (!use_cache) {
        [request setCachePolicy: ASIDoNotWriteToCacheCachePolicy | ASIDoNotReadFromCacheCachePolicy];
    }

    [request setDelegate:self];
    [[sharedSearchQueueManager searchQueue] addOperation:request];

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

-(void)postURL:(NSString *)url withBody:(NSString *)body {
    [self sendBody:body toURL:url usingMethod:@"POST"];
}

-(void)putURL:(NSString *)url withBody:(NSString *)body {
    [self sendBody:body toURL:url usingMethod:@"PUT"];
}

-(void)sendBody:(NSString *)body toURL:(NSString *)url usingMethod:(NSString *)method {
    [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
    NSString *request_url = [self _getFullURL:url];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:request_url]];
    [request setRequestMethod:method];
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

-(ASIHTTPRequest *)getRequestForBlocksWithURL:(NSString *)url withCache:(BOOL)use_cache {
    NSString *request_url = [self _getFullURL:url];
    @autoreleasepool {
        __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:request_url]];

       
        if (!use_cache) {
            [request setCachePolicy: ASIDoNotWriteToCacheCachePolicy | ASIDoNotReadFromCacheCachePolicy];
        }

        [self _signRequest:request withAccessToken:TRUE];
        
        return request;
    }


}


-(ASIHTTPRequest *)getRequestForBlocksWithURL:(NSString *)url {
    return [self getRequestForBlocksWithURL:url withCache:YES];
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
    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"spotseeker.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
    
    BOOL use_oauth = [[plist_values objectForKey:@"use_oauth"] boolValue];
    
    if (!use_oauth) {
        return TRUE;
    }
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"current_user_login"];
    [defaults removeObjectForKey:@"current_user_email"];

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
    if (request.responseStatusCode == 401) {
        // This will at least keep us from continuing to use a failed personal auth token
        if ([REST hasPersonalOAuthToken]) {
            [REST removePersonalOAuthToken];
            return;
        }
    }

    // intentionally cancelling the requests results in a responseStatusCode of 0
    if (!request.responseStatusCode == 0) {
        AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app_delegate showNoNetworkAlert];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [self.delegate requestFromREST:request];
}

@end
