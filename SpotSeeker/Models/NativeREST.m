//
//  NativeREST.m
//  SpaceScout
//
//  Created by pmichaud on 5/7/14.
//
//

#import "NativeREST.h"
#import "REST.h"
#import "GAI.h"
#import "OAuthCore.h"

@implementation NativeREST

@synthesize delegate;
@synthesize status_code;
@synthesize url;
@synthesize received_data;

-(void)getURL:(NSString *)_url withAccessToken:(BOOL)use_token withCache:(BOOL)use_cache {
    url = _url;
    NSString *request_url = [self _getFullURL:_url];
    
    NSURLCacheStoragePolicy cache_value;
    
    if (use_cache) {
        cache_value = NSURLRequestUseProtocolCachePolicy;
    }
    else {
        cache_value = NSURLRequestReloadIgnoringLocalCacheData;
    }
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:request_url]] ;
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:10.0];
    
    [self _signRequest:request withAccessToken:use_token];
    
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection) {
        NSLog(@"No connection!");
        status_code = -1;
        received_data = nil;
    }
    
    [[GAI sharedInstance] dispatch];

}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *http_response = (NSHTTPURLResponse *)response;
    status_code = [http_response statusCode];
    
    // TODO: track the headers
    // NSDictionary *headers = [http_response allHeaderFields];
    //
    
    received_data = [[NSMutableData alloc] init];
    [received_data setLength:0];
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [received_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [self.delegate requestFromNativeREST:self];
}

-(void)_signRequest:(NSMutableURLRequest *)request withAccessToken:(BOOL)use_token {
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

        NSString *oauth_header = OAuthorizationHeader(request.URL, request.HTTPMethod, request.HTTPBody, oauth_key,oauth_secret, access_token, access_token_secret);
        
        [request setValue:oauth_header forHTTPHeaderField:@"Authorization"];
    }
}

-(NSString *)_getFullURL:(NSString *)_url {
    return [[[REST alloc] init] getFullURL:_url];
}

@end
