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
@synthesize search_key;
@synthesize is_default;

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

    NSData *data_source = [[NSData alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"map_defaults" ofType:@"json"]];

    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSArray *values = [parser objectWithData:data_source];
    
    for (NSDictionary *campus_values in values) {
        Campus *current = [[Campus alloc] init];
        current.latitude = [campus_values objectForKey:@"latitude"];
        current.longitude = [campus_values objectForKey:@"longitude"];
        
        current.latitude_delta = [campus_values objectForKey:@"latitude_delta"];
        current.longitude_delta = [campus_values objectForKey:@"longitude_delta"];
        
        current.name = [campus_values objectForKey:@"name"];
        current.search_key = [campus_values objectForKey:@"search_key"];
        
        if ([campus_values objectForKey:@"is_default"]) {
            current.is_default = [NSNumber numberWithBool:true];
        }
        [campuses addObject:current];
    }
    
    return campuses;
}

+(Campus *)getCurrentCampus {
    NSArray *campuses = [Campus getCampuses];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *campus_search_key = [defaults objectForKey:@"current_campus"];
    
    for (Campus *campus in campuses) {
        if (campus_search_key) {
            if ([campus_search_key isEqualToString:campus.search_key]) {
                return campus;
            }
        }
        else {
            if ([campus.is_default boolValue]) {
                return campus;
            }
        }
    }

    NSAssert(false, @"No campus in getCampuses is_default");
    return [[Campus alloc] init];
}

+(void)setCurrentCampus: (Campus *)campus {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:campus.search_key forKey:@"current_campus"];
    [defaults synchronize];
}

@end
