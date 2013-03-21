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
    NSNumber *longitude;
    NSNumber *latitude;
    NSNumber *longitude_delta;
    NSNumber *latitude_delta;
    Boolean is_current;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSNumber *latitude_delta;
@property (nonatomic, retain) NSNumber *longitude_delta;

+(NSArray *) getCampuses;
+(Campus *) getCurrentCampus;

-(double)getLatitude;
-(double)getLongitude;
-(double)getLatitudeDelta;
-(double)getLongitudeDelta;

@end
