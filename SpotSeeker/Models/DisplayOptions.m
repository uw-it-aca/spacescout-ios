//
//  DisplayOptions.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DisplayOptions.h"

@implementation DisplayOptions

@synthesize delegate;

-(void)loadOptions {
    NSData *data_source = [[NSData alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"details_config" ofType:@"json"]];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *types = [parser objectWithData:data_source];

    [self.delegate detailConfiguration:types];

}

@end
