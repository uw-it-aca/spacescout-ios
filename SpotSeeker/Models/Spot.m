//
//  Spot.m
//  SpotSeeker
//
//  Copyright 2012 UW Information Technology, University of Washington
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//

#import "Spot.h"

@implementation Spot

@synthesize delegate;
@synthesize name;
@synthesize id;
@synthesize uri;
@synthesize capacity;
@synthesize display_hours_available;
@synthesize display_access_restrictions;
@synthesize image_urls;
@synthesize organization;
@synthesize manager;
@synthesize extended_info;
@synthesize latitude;
@synthesize longitude;
@synthesize height_from_sea_level;
@synthesize building_name;
@synthesize floor;
@synthesize room_number;
@synthesize description;

- (void) getListBySearch: (NSDictionary *)arguments {
    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"spotseeker.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
    
    NSString *server = [plist_values objectForKey:@"spotseeker_host"];
    
    if (server == NULL) {
        NSLog(@"You need to copy the example_spotseeker.plist file to spotseeker.plist, and provide a spotseeker_host value");
    }
    
    server = [server stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    NSString *list_url = [server stringByAppendingString:[self buildURLWithParams:arguments]];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:list_url]];
    [request setDelegate:self];
    [request startAsynchronous];
}

     
- (void)requestFinished:(ASIHTTPRequest *)request
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];

    if (200 != [request responseStatusCode]) {
        NSLog(@"Code: %i", [request responseStatusCode]);
        // show an error
    }
    
    NSArray *spot_results = [parser objectWithData:[request responseData]];
    NSMutableArray *spot_list = [NSMutableArray arrayWithCapacity:spot_results.count];

    for (NSDictionary *spot_info in spot_results) {      
        Spot *spot = [Spot alloc];
        spot.name = [spot_info objectForKey:@"name"];
        spot.capacity = [spot_info objectForKey:@"capacity"];
        
        NSDictionary *location_info = [spot_info objectForKey:@"location"];
        
        spot.latitude = [location_info objectForKey:@"latitude"];
        spot.longitude = [location_info objectForKey:@"longitude"];
        
        [spot_list addObject:spot];
    }
    
    [delegate searchFinished:spot_list];
    
}   

-(NSString *)buildURLWithParams:(NSDictionary *)param_dictionary {
    NSString *base = @"/api/v1/spot/?";

    for (id key in param_dictionary) {
        NSArray *values = [param_dictionary objectForKey:key];
        for (id value in values) {
            base = [base stringByAppendingFormat:@"%@=%@&", key, value];
        }
    }
    base = [base stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&"]];

    return base;
}

-(void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"Request failed");
}


@end
