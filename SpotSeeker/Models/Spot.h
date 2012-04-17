//
//  Spot.h
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

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest+OAuth.h"
#import "SBJson.h"

@protocol SearchFinished;

@interface Spot : NSObject {
    id <SearchFinished> delegate;
    NSString *name;
    NSString *remote_id;
    NSString *uri;
    NSString *capacity;
    NSString *display_hours_available;
    NSString *display_access_restrictions;
    NSMutableArray *image_urls;
    NSString *organization;
    NSString *manager;
    NSMutableDictionary *extended_info;
    
    // Location data
    NSNumber *latitude;
    NSNumber *longitude;
    NSNumber *height_from_sea_level;
    NSString *building_name;
    NSNumber *floor;
    NSString *room_number;
    NSString *description;
}

- (void) getListBySearch: (NSDictionary *)arguments ;
-(NSString *) buildURLWithParams:(NSDictionary *)param_dictionary;

@property (retain, nonatomic) id <SearchFinished> delegate;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *remote_id;
@property (nonatomic, retain) NSString *uri;
@property (nonatomic, retain) NSString *capacity;
@property (nonatomic, retain) NSString *display_hours_available;
@property (nonatomic, retain) NSString *display_access_restrictions;
@property (nonatomic, retain) NSMutableArray *image_urls;
@property (nonatomic, retain) NSString *organization;
@property (nonatomic, retain) NSString *manager;
@property (nonatomic, retain) NSMutableDictionary *extended_info;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSNumber *height_from_sea_level;
@property (nonatomic, retain) NSString *building_name;
@property (nonatomic, retain) NSNumber *floor;
@property (nonatomic, retain) NSString *room_number;
@property (nonatomic, retain) NSString *description;

@end

@protocol SearchFinished <NSObject>;

-(void) searchFinished:(NSArray *)spots;

@end
