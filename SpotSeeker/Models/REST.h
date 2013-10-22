//
//  REST.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import "KeychainItemWrapper.h"
#import "ASIFormDataRequest+OAuth.h"
#import "ASIHTTPRequest+OAuth.h"
#import "ASIDownloadCache.h"
#import "AppDelegate.h"

@protocol RESTFinished;

@interface REST : NSObject <ASIHTTPRequestDelegate> {
    id <RESTFinished> delegate;
}

@property (retain, nonatomic) id <RESTFinished> delegate;

-(void) getURL:(NSString *)url;
-(void) getURLWithNoAccessToken:(NSString *)url;
-(void)postURL:(NSString *)url withParams:(NSDictionary *)params;
-(NSString *) getFullURL:(NSString *)url;
-(ASIHTTPRequest *)getRequestForBlocksWithURL:(NSString *)url;
-(void)OAuthTokenRequestFromToken:(NSString *)token secret:(NSString *)token_secret andVerifier:(NSString *)verifier;

@end


@protocol RESTFinished <NSObject>;

-(void) requestFromREST:(ASIHTTPRequest *)request;

@end
