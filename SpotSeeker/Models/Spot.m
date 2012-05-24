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
@synthesize remote_id;
@synthesize name;
@synthesize type;
@synthesize uri;
@synthesize capacity;
@synthesize hours_available;
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
@synthesize rest;

- (void) getListBySearch: (NSDictionary *)arguments {
    REST *_rest = [[REST alloc] init];
    _rest.delegate = self;
    [_rest getURL:[self buildURLWithParams:arguments]];
    self.rest = _rest;
}

-(void)requestFromREST:(ASIHTTPRequest *)request {
    SBJsonParser *parser = [[SBJsonParser alloc] init];

    if (200 != [request responseStatusCode]) {
        NSLog(@"Code: %i", [request responseStatusCode]);
        // show an error
    }

    NSArray *spot_results = [parser objectWithData:[request responseData]];
    NSMutableArray *spot_list = [NSMutableArray arrayWithCapacity:spot_results.count];

    for (NSDictionary *spot_info in spot_results) {      
        Spot *spot = [Spot alloc];
        spot.remote_id = [spot_info objectForKey:@"id"];
        spot.name = [spot_info objectForKey:@"name"];
        spot.type = [spot_info objectForKey:@"type"];
        spot.capacity = [spot_info objectForKey:@"capacity"];
        
        NSDictionary *location_info = [spot_info objectForKey:@"location"];
        
        spot.latitude = [location_info objectForKey:@"latitude"];
        spot.longitude = [location_info objectForKey:@"longitude"];
        spot.building_name = [location_info objectForKey:@"building_name"];
        
        NSMutableArray *_image_urls = [[NSMutableArray alloc]init];
        for (NSDictionary *image in [spot_info objectForKey:@"images"]) {
            [_image_urls addObject:[image objectForKey:@"url"]];
        }
        spot.image_urls = _image_urls;
        
        NSMutableDictionary *_extended_info = [[NSMutableDictionary alloc] init];
        NSDictionary *info = [spot_info objectForKey:@"extended_info"];
        for (NSString *key in info) {
            NSString *value = [info objectForKey:key];
            [_extended_info setObject:value forKey:key];
        }
        spot.extended_info = _extended_info;
        
        NSMutableDictionary *_hours_available = [[NSMutableDictionary alloc] init];
        NSDictionary *hours = [spot_info objectForKey:@"available_hours"];

        for (NSString *day in hours) {
            NSMutableArray *windows = [[NSMutableArray alloc] init];
            NSArray *source_windows = [hours objectForKey:day];
            for (NSArray *source_window in source_windows) {
                NSMutableArray *window = [[NSMutableArray alloc] init];
                
                NSArray *start_parts = [[source_window objectAtIndex:0] componentsSeparatedByString:@":"];
                
                NSDateComponents *start_date = [[NSDateComponents alloc] init];
                start_date.hour = [ [start_parts objectAtIndex:0] intValue ];
                start_date.minute = [ [start_parts objectAtIndex:1] intValue ];

                NSArray *end_parts = [[source_window objectAtIndex:1] componentsSeparatedByString:@":"];

                NSDateComponents *end_date = [[NSDateComponents alloc] init];
                end_date.hour = [ [end_parts objectAtIndex:0] intValue ];
                end_date.minute = [ [end_parts objectAtIndex:1] intValue ];
  
                [window addObject:start_date];
                [window addObject:end_date];
                [windows addObject:window];
            }
            [_hours_available setObject:windows forKey:day];
        }
        spot.hours_available = _hours_available;
    
        [spot_list addObject:spot];
    }
    
    [delegate searchFinished:spot_list];
    
}   

-(NSString *)buildURLWithParams:(NSDictionary *)param_dictionary {
    NSString *base = @"/api/v1/spot/?";

    for (id key in param_dictionary) {
        NSArray *values = [param_dictionary objectForKey:key];
        for (id value in values) {
            NSString *value_string = [[NSString alloc] initWithFormat:@"%@", value];
            // From https://devforums.apple.com/message/15674#15674
            NSMutableString *encoded_value = [NSMutableString stringWithString: [value_string stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy]];
             
            [encoded_value replaceOccurrencesOfString:@"$" withString:@"%24" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded_value length])];
            [encoded_value replaceOccurrencesOfString:@"&" withString:@"%26" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded_value length])];
            [encoded_value replaceOccurrencesOfString:@"+" withString:@"%2B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded_value length])];
            [encoded_value replaceOccurrencesOfString:@"," withString:@"%2C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded_value length])];
            [encoded_value replaceOccurrencesOfString:@"/" withString:@"%2F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded_value length])];
            [encoded_value replaceOccurrencesOfString:@":" withString:@"%3A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded_value length])];
            [encoded_value replaceOccurrencesOfString:@";" withString:@"%3B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded_value length])];
            [encoded_value replaceOccurrencesOfString:@"=" withString:@"%3D" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded_value length])];
            [encoded_value replaceOccurrencesOfString:@"?" withString:@"%3F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded_value length])];
            [encoded_value replaceOccurrencesOfString:@"@" withString:@"%40" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded_value length])];
            [encoded_value replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded_value length])];
            [encoded_value replaceOccurrencesOfString:@"\t" withString:@"%09" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded_value length])];
            [encoded_value replaceOccurrencesOfString:@"#" withString:@"%23" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded_value length])];
            [encoded_value replaceOccurrencesOfString:@"<" withString:@"%3C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded_value length])];
            [encoded_value replaceOccurrencesOfString:@">" withString:@"%3E" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded_value length])];
            [encoded_value replaceOccurrencesOfString:@"\"" withString:@"%22" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded_value length])];
            [encoded_value replaceOccurrencesOfString:@"\n" withString:@"%0A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded_value length])];
            
            base = [base stringByAppendingFormat:@"%@=%@&", key, encoded_value];
        }
    }
    base = [base stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&"]];

    return base;
}

-(void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"Request failed");
}


@end
