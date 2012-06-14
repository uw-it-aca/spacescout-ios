//
//  REST.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest+OAuth.h"

@protocol RESTFinished;

@interface REST : NSObject {
    id <RESTFinished> delegate;
}

@property (retain, nonatomic) id <RESTFinished> delegate;

-(void) getURL:(NSString *)url;
-(ASIHTTPRequest *)getRequestForBlocksWithURL:(NSString *)url;

@end


@protocol RESTFinished <NSObject>;

-(void) requestFromREST:(ASIHTTPRequest *)request;

@end
