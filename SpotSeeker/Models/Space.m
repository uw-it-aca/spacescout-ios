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

#import "Space.h"
#import "Favorites.h"

@implementation Space

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
@synthesize distance_from_user;
@synthesize modifified_date;
@synthesize is_favorite;

static NSMutableDictionary *favorite_space_ids;
static NSDate *last_favorite_update;

const float FAVORITES_REFRESH_INTERVAL = 10.0;

+(void)clearFavoritesCache {
    last_favorite_update = nil;
}

-(void) getListByFavorites {
    REST *_rest = [[REST alloc] init];
    _rest.delegate = self;

    
    [_rest getURL:@"/api/v1/user/me/favorites/"];
    self.rest = _rest;
}

- (void) getListBySearch: (NSDictionary *)arguments {
    if (!last_favorite_update || [[NSDate date] timeIntervalSinceDate:last_favorite_update] > FAVORITES_REFRESH_INTERVAL) {
        last_favorite_update = [NSDate date];
        REST *_rest = [[REST alloc] init];
        __weak ASIHTTPRequest *request = [_rest getRequestForBlocksWithURL:@"/api/v1/user/me/favorites/"];
        [request setCompletionBlock:^{
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSArray *spot_results = [parser objectWithData:[request responseData]];
            favorite_space_ids = [[NSMutableDictionary alloc] init];
            
            [Favorites setLocalCacheFromRESTData:spot_results];
            for (NSDictionary *spot_info in spot_results) {
                NSString *fav_remote_id = [spot_info objectForKey:@"id"];
                [favorite_space_ids setObject:[NSObject alloc] forKey:fav_remote_id];
            }
            [self _getListBySearch:arguments];
        }];
        
        [request setFailedBlock:^{
            // Go on anyway, no need to stop the app
            if ([request responseStatusCode] == 401) {
                // If we're unauthorized, but we have a personal oauth token, drop it, because it
                // obviously isn't helping us!
                if ([REST hasPersonalOAuthToken]) {
                    [REST removePersonalOAuthToken];
                }
                
            }
            else {
                NSLog(@"Failure on favorites!, %i", [request responseStatusCode]);
            }
            [self _getListBySearch:arguments];

        }];
        
        [request startAsynchronous];
    }
    else {
        [self _getListBySearch:arguments];
        // fetch now
    }
}

-(void) _getListBySearch: (NSDictionary *) arguments {
    REST *_rest = [[REST alloc] init];
    _rest.delegate = self;
    
    NSString *url =[self buildURLWithParams:arguments];
    [_rest getURL:url];
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

    float min_long = 9999;
    float min_lat = 9999;
    float max_long = -99999;
    float max_lat = -99999;
    for (NSDictionary *spot_info in spot_results) {
        Space *spot = [Space alloc];
        spot.remote_id = [spot_info objectForKey:@"id"];
        spot.name = [spot_info objectForKey:@"name"];
        
        if ([favorite_space_ids objectForKey:spot.remote_id]) {
            spot.is_favorite = true;
        }
        else {
            spot.is_favorite = false;
        }
        
        id type_basics = [spot_info objectForKey:@"type"];
        NSString *type_class = [NSString stringWithFormat:@"%@", [type_basics class]];
        if ([type_class isEqualToString:@"__NSCFString"]) {
            NSMutableArray *types = [[NSMutableArray alloc] init];
            [types addObject:type_basics];
            spot.type = types;
        }
        else {
            spot.type = [spot_info objectForKey:@"type"];
        }
        
        if (![[[spot_info objectForKey:@"capacity"] class] isSubclassOfClass:[NSNull class]]) {
            spot.capacity = [spot_info objectForKey:@"capacity"];
        }
               
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss+'00:00'";

        spot.modifified_date = [dateFormatter dateFromString:[spot_info objectForKey:@"last_modified"]];
        
        NSDictionary *location_info = [spot_info objectForKey:@"location"];

        if ([[location_info objectForKey:@"latitude"] floatValue] > max_lat) {
            max_lat = [[location_info objectForKey:@"latitude"] floatValue];
        }
        if ([[location_info objectForKey:@"longitude"] floatValue] > max_long) {
            max_long = [[location_info objectForKey:@"longitude"] floatValue];
        }
        if ([[location_info objectForKey:@"latitude"] floatValue] < min_lat) {
            min_lat = [[location_info objectForKey:@"latitude"] floatValue];
        }
        if ([[location_info objectForKey:@"longitude"] floatValue] < min_long) {
            min_long = [[location_info objectForKey:@"longitude"] floatValue];
        }

        
        spot.latitude = [location_info objectForKey:@"latitude"];
        spot.longitude = [location_info objectForKey:@"longitude"];
        spot.building_name = [location_info objectForKey:@"building_name"];
        spot.room_number = [location_info objectForKey:@"room_number"];
        spot.floor = [location_info objectForKey:@"floor"];
        
        NSMutableArray *_image_urls = [[NSMutableArray alloc]init];
        for (NSDictionary *image in [spot_info objectForKey:@"images"]) {
            NSNumber *height = [image objectForKey:@"height"];
            NSNumber *width = [image objectForKey:@"width"];
            
            if (([height intValue] < 400) && ([width intValue] < 400)) {
                [_image_urls addObject:[image objectForKey:@"url"]];
            }
            else {
                int new_height;
                int new_width;
                if (height < width) {
                    float ratio = 400 / [width floatValue];
                    new_width = 400;
                    new_height = (int)(ratio * [height floatValue]);
                }
                else {
                    float ratio = 400 / [height floatValue];
                    new_height = 400;
                    new_width = (int)(ratio * [width floatValue]);
                }
                NSString *thumb_url = [NSString stringWithFormat:@"%@/%ix%i", [image objectForKey:@"thumbnail_root"], new_width, new_height];
                [_image_urls addObject:thumb_url];
            }
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

#pragma mark -
#pragma mark sorting for list views

-(NSComparisonResult)compareToSpot:(Space *)spot {
    /*
    Proximity to current location (when no location authorized, do not show the distance in the list view and sort alpha by building instead)
    Alpha by building name
    Floor number (basement, 1, 2, etc. -- OR, lower level, main floor, upper level)
    Room number
    Alpha by space* name
    By room type (according to the order we listed in the search screen)
    By number of seats (ascending)
     */
     
    if (self.distance_from_user && spot.distance_from_user) {       
        NSNumber *d1 = [NSNumber numberWithInt:(int)(roundf([self.distance_from_user floatValue] * 100.0))];
        NSNumber *d2 = [NSNumber numberWithInt:(int)(roundf([spot.distance_from_user floatValue] * 100.0))];

        if (![d1 isEqualToNumber:d2]) {
            return [d1 compare:d2];
        }
    }
    
    if (![self.building_name isEqualToString:spot.building_name]) {
        return [self.building_name compare:spot.building_name];
    }
    
    NSNumber *my_floor = [self numberFromFloorString:self.floor];
    NSNumber *their_floor = [self numberFromFloorString:spot.floor];
    
    if (![my_floor isEqualToNumber:their_floor]) {
        return [my_floor compare:their_floor];
    }

    if (![self.room_number isEqualToString:spot.room_number]) {
        return [self.room_number compare:spot.room_number];
    }

    if (![self.name isEqualToString:spot.name]) {
        return [self.name compare:spot.name];
    }

    NSNumber *my_type = [self numberFromSpotTypes:self.type];
    NSNumber *their_type = [self numberFromSpotTypes:spot.type];
    
    if (![my_type isEqualToNumber:their_type]) {
        return [my_type compare:their_type];
    }
    
    if (![self.capacity isEqualToNumber:spot.capacity]) {
        return [self.capacity compare:spot.capacity];
    }
    
    return NSOrderedSame;
}

-(NSNumber *)numberFromSpotTypes:(NSMutableArray *)spot_types {
    NSNumber *min = [NSNumber numberWithInt:99];
    for (NSString *_type in spot_types) {
        NSNumber *type_val = [self numberFromSpotType:_type];
        if ([type_val intValue] < [min intValue]) {
            min = type_val;
        }
    }
    return min;
}

-(NSNumber *)numberFromSpotType:(NSString *)spot_type {
    if ([spot_type isEqualToString:@"study_room"]) {
        return [NSNumber numberWithInt:0];
    }
    if ([spot_type isEqualToString:@"study_space"]) {
        return [NSNumber numberWithInt:1];
    }
    if ([spot_type isEqualToString:@"computer_lab"]) {
        return [NSNumber numberWithInt:2];
    }
    if ([spot_type isEqualToString:@"studio"]) {
        return [NSNumber numberWithInt:3];
    }
    if ([spot_type isEqualToString:@"conference"]) {
        return [NSNumber numberWithInt:4];
    }
    if ([spot_type isEqualToString:@"open"]) {
        return [NSNumber numberWithInt:5];
    }
    if ([spot_type isEqualToString:@"lounge"]) {
        return [NSNumber numberWithInt:6];
    }
    if ([spot_type isEqualToString:@"cafe"]) {
        return [NSNumber numberWithInt:7];
    }
    if ([spot_type isEqualToString:@"outdoors"]) {
        return [NSNumber numberWithInt:8];
    }

    return [NSNumber numberWithInt:-1];
}

-(NSNumber *)numberFromFloorString:(NSString *)_floor {
    if (_floor == nil) {
        return [NSNumber numberWithInt:-10];        
    }
    if ([_floor isEqualToString:@"L1"]) {
        return [NSNumber numberWithInt:-1];        
    }
    if ([_floor isEqualToString:@"L2"]) {
        return [NSNumber numberWithInt:-2];        
    }
    if ([_floor isEqualToString:@"Basement"]) {
        return [NSNumber numberWithInt:-1];
    }
    
    if ([_floor isEqualToString:@"Lower level"]) {
        return [NSNumber numberWithInt:-1];
    }
    
    if ([_floor isEqualToString:@"Main floor"]) {
        return [NSNumber numberWithInt:1];
    }
    
    if ([_floor isEqualToString:@"Upper floor"]) {
        return [NSNumber numberWithInt:2];
    }
    
    if ([_floor isEqualToString:@"Upper level"]) {
        return [NSNumber numberWithInt:2];
    }

    NSScanner *floor_finder = [NSScanner scannerWithString:_floor];
    int number = 0;
    [floor_finder scanInt:&number];
    
    if (number) {
        return [NSNumber numberWithInt:number];
    }
    
    return [NSNumber numberWithInt:-10];

}

-(BOOL)isOpenNow {
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:now];
    
    NSArray *day_lookup = [[NSArray alloc] initWithObjects:@"", @"sunday", @"monday", @"tuesday", @"wednesday", @"thursday", @"friday", @"saturday", nil];
    
    NSMutableArray *windows = [hours_available objectForKey:[day_lookup objectAtIndex:[components weekday]]];
    
    for (NSMutableArray *window in windows) {
        NSDateComponents *start = [window objectAtIndex:0];
        NSDateComponents *end   = [window objectAtIndex:1];
        
        [components setHour:[start hour]];
        [components setMinute:[start minute]];
        
        NSDate *start_cmp = [calendar dateFromComponents:components];
        
        [components setHour:[end hour]];
        [components setMinute:[end minute]];
        
        NSDate *end_cmp = [calendar dateFromComponents:components];
        
        // If the start time is before or equal to now, and the end time is after or equal to now, we're open
        if (([start_cmp compare:now] != NSOrderedDescending) && ([end_cmp compare:now] != NSOrderedAscending)) {
            return true;
        }
        
    }
    
    return false;
}


@end
