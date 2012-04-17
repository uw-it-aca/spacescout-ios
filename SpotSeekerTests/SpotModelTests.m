//
//  SpotModelTests.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SpotModelTests.h"

@implementation SpotModelTests

-(void)testEmptyQuery {
    NSString *result = [[Spot alloc] buildURLWithParams:[[NSDictionary alloc] init]];
    
    STAssertEqualObjects(result, @"/api/v1/spot/?", @"empty query");
}

-(void)testSingleValue {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[[NSArray alloc] initWithObjects: @"search_value", nil] forKey:@"search_key"];
    
    NSString *result = [[Spot alloc] buildURLWithParams:dict];
    
    STAssertEqualObjects(result, @"/api/v1/spot/?search_key=search_value", @"single value test");
}

-(void)testMultiValue {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[[NSArray alloc] initWithObjects: @"search_value2", @"search_value1", nil] forKey:@"search_key"];
    
    NSString *result = [[Spot alloc] buildURLWithParams:dict];
    
    STAssertEqualObjects(result, @"/api/v1/spot/?search_key=search_value2&search_key=search_value1", @"multi-value test");
}

-(void)testEncoding {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[[NSArray alloc] initWithObjects: @"#\n&?%", nil] forKey:@"search_key"];
    
    NSString *result = [[Spot alloc] buildURLWithParams:dict];
    
    STAssertEqualObjects(result, @"/api/v1/spot/?search_key=%23%0A%26%3F%25", @"multi-value test");
}


@end
