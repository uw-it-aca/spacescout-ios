//
//  Campus.m
//  SpaceScout
//
//  Created by Patrick Michaud on 3/21/13.
//
//

#import "Campus.h"

@implementation Campus
@synthesize name;
@synthesize latitude;
@synthesize longitude;
@synthesize latitude_delta;
@synthesize longitude_delta;

-(double)getLatitude {
    return [self.latitude doubleValue];
}

-(double)getLongitude {
    return [self.longitude doubleValue];
}

-(double)getLatitudeDelta {
    return [self.latitude_delta doubleValue];
}

-(double)getLongitudeDelta {
    return [self.longitude_delta doubleValue];
}

+(NSArray *)getCampuses {
    
    NSMutableArray *campuses = [[NSMutableArray alloc] init];
    [campuses addObject:[Campus getCurrentCampus]];
    
    return campuses;
}

+(Campus *)getCurrentCampus {
    NSData *data_source = [[NSData alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"map_defaults" ofType:@"json"]];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *values = [parser objectWithData:data_source];
    
    Campus *current = [[Campus alloc] init];
    current.latitude = [values objectForKey:@"latitude"];
    current.longitude = [values objectForKey:@"longitude"];

    current.latitude_delta = [values objectForKey:@"latitude_delta"];
    current.longitude_delta = [values objectForKey:@"longitude_delta"];

    current.name = @"Demo Campus";
    
    return current;
}

@end
