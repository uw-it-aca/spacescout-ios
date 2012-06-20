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

#pragma mark -
#pragma mark sorting tests

-(void)testSpotDistance {
    Spot *alpha = [[Spot alloc] init];
    Spot *beta = [[Spot alloc] init];
    Spot *gamma = [[Spot alloc] init];
    
    alpha.distance_from_user = [NSNumber numberWithFloat:0.010];
    beta.distance_from_user = [NSNumber numberWithFloat:1.0201];
    gamma.distance_from_user = [NSNumber numberWithFloat:1.0202];
        
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    STAssertEquals([beta compareToSpot:alpha], NSOrderedDescending, @"Further things sort properly");
    STAssertEquals([beta compareToSpot:gamma], NSOrderedSame, @"Only comparing significant digits");
}

-(void)testBuildingName {
    Spot *alpha = [[Spot alloc] init];
    Spot *beta = [[Spot alloc] init];
    Spot *gamma = [[Spot alloc] init];

    
    alpha.distance_from_user = [NSNumber numberWithFloat:1.00];
    beta.distance_from_user = [NSNumber numberWithFloat:1.00];
    gamma.distance_from_user = [NSNumber numberWithFloat:1.00];

    alpha.building_name = @"AA";
    beta.building_name = @"BB";
    gamma.building_name = @"BB";
    
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    STAssertEquals([beta compareToSpot:alpha], NSOrderedDescending, @"Further things sort properly");
    STAssertEquals([beta compareToSpot:gamma], NSOrderedSame, @"Only comparing significant digits");   
}

-(void)testFloor {
    Spot *alpha = [[Spot alloc] init];
    Spot *beta = [[Spot alloc] init];
    Spot *gamma = [[Spot alloc] init];
    
    
    alpha.distance_from_user = [NSNumber numberWithFloat:1.00];
    beta.distance_from_user = [NSNumber numberWithFloat:1.00];
    gamma.distance_from_user = [NSNumber numberWithFloat:1.00];
    
    alpha.building_name = @"AA";
    beta.building_name = @"AA";
    gamma.building_name = @"AA";

    alpha.floor = @"Basement";
    beta.floor = @"Main floor";
    gamma.floor = @"Main floor";
    
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    STAssertEquals([beta compareToSpot:alpha], NSOrderedDescending, @"Further things sort properly");
    STAssertEquals([beta compareToSpot:gamma], NSOrderedSame, @"Only comparing significant digits");   
    
    // Need to do more tests here...
    Spot *delta = [[Spot alloc] init];
    Spot *epsilon = [[Spot alloc] init];
    Spot *zeta = [[Spot alloc] init];

    delta.distance_from_user = [NSNumber numberWithFloat:1.00];
    epsilon.distance_from_user = [NSNumber numberWithFloat:1.00];
    zeta.distance_from_user = [NSNumber numberWithFloat:1.00];
    
    delta.building_name = @"AA";
    epsilon.building_name = @"AA";
    zeta.building_name = @"AA";
    
    delta.floor = @"Upper floor";
    epsilon.floor = @"1st floor";
    zeta.floor = @"3rd floor";

    STAssertEquals([beta compareToSpot:delta], NSOrderedAscending, @"Closer things sort properly");
    STAssertEquals([delta compareToSpot:zeta], NSOrderedAscending, @"Closer things sort properly");
    STAssertEquals([alpha compareToSpot:zeta], NSOrderedAscending, @"Closer things sort properly");
    
    STAssertEquals([epsilon compareToSpot:beta], NSOrderedSame, @"Only comparing significant digits");   
}

-(void)testRoomNumber {
    Spot *alpha = [[Spot alloc] init];
    Spot *beta = [[Spot alloc] init];
    Spot *gamma = [[Spot alloc] init];
    
    
    alpha.distance_from_user = [NSNumber numberWithFloat:1.00];
    beta.distance_from_user = [NSNumber numberWithFloat:1.00];
    gamma.distance_from_user = [NSNumber numberWithFloat:1.00];
    
    alpha.building_name = @"AA";
    beta.building_name = @"AA";
    gamma.building_name = @"AA";
    
    alpha.floor = @"1st";
    beta.floor = @"1st";
    gamma.floor = @"1st";
    
    alpha.room_number = @"010";
    beta.room_number = @"210";
    gamma.room_number = @"210";
    
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    STAssertEquals([beta compareToSpot:alpha], NSOrderedDescending, @"Further things sort properly");
    STAssertEquals([beta compareToSpot:gamma], NSOrderedSame, @"Only comparing significant digits");   

}

-(void)testSpotName {
    Spot *alpha = [[Spot alloc] init];
    Spot *beta = [[Spot alloc] init];
    Spot *gamma = [[Spot alloc] init];
    
    
    alpha.distance_from_user = [NSNumber numberWithFloat:1.00];
    beta.distance_from_user = [NSNumber numberWithFloat:1.00];
    gamma.distance_from_user = [NSNumber numberWithFloat:1.00];
    
    alpha.building_name = @"AA";
    beta.building_name = @"AA";
    gamma.building_name = @"AA";
    
    alpha.floor = @"1st";
    beta.floor = @"1st";
    gamma.floor = @"1st";
    
    alpha.room_number = @"210";
    beta.room_number = @"210";
    gamma.room_number = @"210";

    alpha.name = @"AA";
    beta.name = @"BB";
    gamma.name = @"BB";
    
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    STAssertEquals([beta compareToSpot:alpha], NSOrderedDescending, @"Further things sort properly");
    STAssertEquals([beta compareToSpot:gamma], NSOrderedSame, @"Only comparing significant digits");   
    
}

-(void)testSpotType {
    Spot *alpha = [[Spot alloc] init];
    Spot *beta = [[Spot alloc] init];
    Spot *gamma = [[Spot alloc] init];
    
    
    alpha.distance_from_user = [NSNumber numberWithFloat:1.00];
    beta.distance_from_user = [NSNumber numberWithFloat:1.00];
    gamma.distance_from_user = [NSNumber numberWithFloat:1.00];
    
    alpha.building_name = @"AA";
    beta.building_name = @"AA";
    gamma.building_name = @"AA";
    
    alpha.floor = @"1st";
    beta.floor = @"1st";
    gamma.floor = @"1st";
    
    alpha.room_number = @"210";
    beta.room_number = @"210";
    gamma.room_number = @"210";
    
    alpha.name = @"BB";
    beta.name = @"BB";
    gamma.name = @"BB";

    alpha.type = @"study_room";
    beta.type = @"study_space";
    gamma.type = @"study_space";
    
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    STAssertEquals([beta compareToSpot:alpha], NSOrderedDescending, @"Further things sort properly");
    STAssertEquals([beta compareToSpot:gamma], NSOrderedSame, @"Only comparing significant digits");   

    alpha.type = @"study_space";
    beta.type = @"computer_lab";
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    
    alpha.type = @"computer_lab";
    beta.type = @"studio";
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");

    alpha.type = @"studio";
    beta.type = @"conference";
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    
    alpha.type = @"conference";
    beta.type = @"open";
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    
    alpha.type = @"open";
    beta.type = @"lounge";
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    
    alpha.type = @"lounge";
    beta.type = @"cafe";
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    
    alpha.type = @"cafe";
    beta.type = @"outdoors";
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    
    alpha.type = @"study_room";
    beta.type = @"outdoors";
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    
    
}

-(void)testSpotCapacity {
    Spot *alpha = [[Spot alloc] init];
    Spot *beta = [[Spot alloc] init];
    Spot *gamma = [[Spot alloc] init];
    
    
    alpha.distance_from_user = [NSNumber numberWithFloat:1.00];
    beta.distance_from_user = [NSNumber numberWithFloat:1.00];
    gamma.distance_from_user = [NSNumber numberWithFloat:1.00];
    
    alpha.building_name = @"AA";
    beta.building_name = @"AA";
    gamma.building_name = @"AA";
    
    alpha.floor = @"1st";
    beta.floor = @"1st";
    gamma.floor = @"1st";
    
    alpha.room_number = @"210";
    beta.room_number = @"210";
    gamma.room_number = @"210";
    
    alpha.name = @"BB";
    beta.name = @"BB";
    gamma.name = @"BB";
    
    alpha.type = @"study_space";
    beta.type = @"study_space";
    gamma.type = @"study_space";
    
    alpha.capacity = [NSNumber numberWithInt:10];
    beta.capacity = [NSNumber numberWithInt:20];
    gamma.capacity = [NSNumber numberWithInt:20];
        
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    STAssertEquals([beta compareToSpot:alpha], NSOrderedDescending, @"Further things sort properly");
    STAssertEquals([beta compareToSpot:gamma], NSOrderedSame, @"Only comparing significant digits");   
}

@end

