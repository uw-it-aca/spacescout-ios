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
#import "REST.h"
#import "Campus.h"

@protocol SearchFinished;

@interface Space : NSObject <RESTFinished> {
    id <SearchFinished> delegate;
    NSString *remote_id;
    NSString *name;
    NSMutableArray *type;
    NSString *uri;
    NSNumber *capacity;
    NSMutableDictionary *hours_available;
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
    NSString *floor;
    NSString *room_number;
    NSString *description;
    REST *rest;
    
    // For the list view, in miles
    NSNumber *distance_from_user;
}

- (void) getListByFavorites;
- (void) getListBySearch: (NSDictionary *)arguments ;

-(NSString *) buildURLWithParams:(NSDictionary *)param_dictionary;
-(NSComparisonResult)compareToSpot:(Space *)spot;
-(BOOL)isOpenNow;

@property (retain, nonatomic) id <SearchFinished> delegate;

@property (nonatomic, retain) REST *rest;
@property (nonatomic, retain) NSString *remote_id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *type;
@property (nonatomic, retain) NSString *uri;
@property (nonatomic, retain) NSNumber *capacity;
@property (nonatomic, retain) NSMutableDictionary *hours_available;
@property (nonatomic, retain) NSString *display_access_restrictions;
@property (nonatomic, retain) NSMutableArray *image_urls;
@property (nonatomic, retain) NSString *organization;
@property (nonatomic, retain) NSString *manager;
@property (nonatomic, retain) NSMutableDictionary *extended_info;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSNumber *height_from_sea_level;
@property (nonatomic, retain) NSString *building_name;
@property (nonatomic, retain) NSString *floor;
@property (nonatomic, retain) NSString *room_number;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSNumber *distance_from_user;
@property (nonatomic, retain) NSDate *modifified_date;

@end

@protocol SearchFinished <NSObject>;

-(void) searchFinished:(NSArray *)spots;

@end

