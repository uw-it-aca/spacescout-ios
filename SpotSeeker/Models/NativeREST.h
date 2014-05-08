//
//  NativeREST.h
//  SpaceScout
//
//  Created by pmichaud on 5/7/14.
//
//

#import <Foundation/Foundation.h>

@protocol NativeRESTFinished;

@interface NativeREST : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    id <NativeRESTFinished> delegate;
}

@property (retain, nonatomic) id <NativeRESTFinished> delegate;
@property (retain, nonatomic) NSString *url;
@property (nonatomic) NSInteger status_code;
@property (retain, nonatomic) NSMutableData *received_data;

-(void)getURL:(NSString *)url withAccessToken:(BOOL)use_token withCache:(BOOL)use_cache;

@end

@protocol NativeRESTFinished <NSObject>;

-(void) requestFromNativeREST:(NativeREST *)rest;

@end
