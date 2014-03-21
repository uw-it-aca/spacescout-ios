//
//  Campus.h
//  SpaceScout
//
//  Created by Patrick Michaud on 3/21/13.
//
//

#import <Foundation/Foundation.h>
#import "SBJson.h"

@interface Campus : NSObject {
    NSString *name;
    NSString *screen_title;
    NSString *search_key;
    NSNumber *longitude;
    NSNumber *latitude;
    NSNumber *longitude_delta;
    NSNumber *latitude_delta;
    NSNumber *is_default;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *screen_title;
@property (nonatomic, retain) NSString *search_key;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSNumber *latitude_delta;
@property (nonatomic, retain) NSNumber *longitude_delta;
@property (nonatomic, retain) NSNumber *is_default;

+(NSArray *) getCampuses;
+(Campus *) getCurrentCampus;
+(Campus *) getNextCampus;
+(void)setCurrentCampus: (Campus *)campus;
+(void)setNextCampus: (Campus *) campus;
+(void)clearNextCampus;

-(double)getLatitude;
-(double)getLongitude;
-(double)getLatitudeDelta;
-(double)getLongitudeDelta;

@end
