//
//  DisplayOptions.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJson.h"

@protocol DisplayOptionsLoaded;

@interface DisplayOptions : NSObject {
    id <DisplayOptionsLoaded> delegate;
}

-(void)loadOptions;

@property (retain, nonatomic) id <DisplayOptionsLoaded> delegate;

@end



@protocol DisplayOptionsLoaded <NSObject>;

-(void) detailConfiguration:(NSDictionary *)config;

@end