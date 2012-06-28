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
    NSString *result = [[Space alloc] buildURLWithParams:[[NSDictionary alloc] init]];
    
    STAssertEqualObjects(result, @"/api/v1/spot/?", @"empty query");
}

-(void)testSingleValue {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[[NSMutableArray alloc] initWithObjects: @"search_value", nil] forKey:@"search_key"];
    
    NSString *result = [[Space alloc] buildURLWithParams:dict];
    
    STAssertEqualObjects(result, @"/api/v1/spot/?search_key=search_value", @"single value test");
}

-(void)testMultiValue {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[[NSMutableArray alloc] initWithObjects: @"search_value2", @"search_value1", nil] forKey:@"search_key"];
    
    NSString *result = [[Space alloc] buildURLWithParams:dict];
    
    STAssertEqualObjects(result, @"/api/v1/spot/?search_key=search_value2&search_key=search_value1", @"multi-value test");
}

-(void)testEncoding {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[[NSMutableArray alloc] initWithObjects: @"#\n&?%", nil] forKey:@"search_key"];
    
    NSString *result = [[Space alloc] buildURLWithParams:dict];
    
    STAssertEqualObjects(result, @"/api/v1/spot/?search_key=%23%0A%26%3F%25", @"multi-value test");
}

#pragma mark -
#pragma mark sorting tests

-(void)testSpotDistance {
    Space *alpha = [[Space alloc] init];
    Space *beta = [[Space alloc] init];
    Space *gamma = [[Space alloc] init];
    
    alpha.distance_from_user = [NSNumber numberWithFloat:0.010];
    beta.distance_from_user = [NSNumber numberWithFloat:1.0201];
    gamma.distance_from_user = [NSNumber numberWithFloat:1.0202];
        
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    STAssertEquals([beta compareToSpot:alpha], NSOrderedDescending, @"Further things sort properly");
    STAssertEquals([beta compareToSpot:gamma], NSOrderedSame, @"Only comparing significant digits");
}

-(void)testBuildingName {
    Space *alpha = [[Space alloc] init];
    Space *beta = [[Space alloc] init];
    Space *gamma = [[Space alloc] init];

    
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
    Space *alpha = [[Space alloc] init];
    Space *beta = [[Space alloc] init];
    Space *gamma = [[Space alloc] init];
    
    
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
    Space *delta = [[Space alloc] init];
    Space *epsilon = [[Space alloc] init];
    Space *zeta = [[Space alloc] init];

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
    Space *alpha = [[Space alloc] init];
    Space *beta = [[Space alloc] init];
    Space *gamma = [[Space alloc] init];
    
    
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
    Space *alpha = [[Space alloc] init];
    Space *beta = [[Space alloc] init];
    Space *gamma = [[Space alloc] init];
    
    
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
    Space *alpha = [[Space alloc] init];
    Space *beta = [[Space alloc] init];
    Space *gamma = [[Space alloc] init];
    
    
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

    alpha.type = [[NSMutableArray alloc] initWithObjects:@"study_room", nil];
    beta.type = [[NSMutableArray alloc] initWithObjects:@"study_space", nil];
    gamma.type = [[NSMutableArray alloc] initWithObjects:@"study_space", nil];
    
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    STAssertEquals([beta compareToSpot:alpha], NSOrderedDescending, @"Further things sort properly");
    STAssertEquals([beta compareToSpot:gamma], NSOrderedSame, @"Only comparing significant digits");   

    alpha.type = [[NSMutableArray alloc] initWithObjects:@"study_space", nil];
    beta.type = [[NSMutableArray alloc] initWithObjects:@"computer_lab", nil];
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    
    alpha.type = [[NSMutableArray alloc] initWithObjects:@"computer_lab", nil];
    beta.type = [[NSMutableArray alloc] initWithObjects:@"studio", nil];
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");

    alpha.type = [[NSMutableArray alloc] initWithObjects:@"studio", nil];
    beta.type = [[NSMutableArray alloc] initWithObjects:@"conference", nil];
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    
    alpha.type = [[NSMutableArray alloc] initWithObjects:@"conference", nil];
    beta.type = [[NSMutableArray alloc] initWithObjects:@"open", nil];
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    
    alpha.type = [[NSMutableArray alloc] initWithObjects:@"open", nil];
    beta.type = [[NSMutableArray alloc] initWithObjects:@"lounge", nil];
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    
    alpha.type = [[NSMutableArray alloc] initWithObjects:@"lounge", nil];
    beta.type = [[NSMutableArray alloc] initWithObjects:@"cafe", nil];
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    
    alpha.type = [[NSMutableArray alloc] initWithObjects:@"cafe", nil];
    beta.type = [[NSMutableArray alloc] initWithObjects:@"outdoors", nil];
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    
    alpha.type = [[NSMutableArray alloc] initWithObjects:@"study_room", nil];
    beta.type = [[NSMutableArray alloc] initWithObjects:@"outdoors", nil];
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    
    // Test spots w/ multiple types
    alpha.type = [[NSMutableArray alloc] initWithObjects:@"cafe", @"study_room", nil];
    beta.type = [[NSMutableArray alloc] initWithObjects:@"lounge", nil];
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");   
    
}

-(void)testSpotCapacity {
    Space *alpha = [[Space alloc] init];
    Space *beta = [[Space alloc] init];
    Space *gamma = [[Space alloc] init];
    
    
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
    
    alpha.type = [[NSMutableArray alloc] initWithObjects:@"study_space", nil];
    beta.type = [[NSMutableArray alloc] initWithObjects:@"study_space", nil];
    gamma.type = [[NSMutableArray alloc] initWithObjects:@"study_space", nil];
    
    alpha.capacity = [NSNumber numberWithInt:10];
    beta.capacity = [NSNumber numberWithInt:20];
    gamma.capacity = [NSNumber numberWithInt:20];
        
    STAssertEquals([alpha compareToSpot:beta], NSOrderedAscending, @"Closer things sort properly");
    STAssertEquals([beta compareToSpot:alpha], NSOrderedDescending, @"Further things sort properly");
    STAssertEquals([beta compareToSpot:gamma], NSOrderedSame, @"Only comparing significant digits");   
}

@end

