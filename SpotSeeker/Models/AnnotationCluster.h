//
//  AnnotationClusters.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Spot.h"

@interface AnnotationCluster : NSObject {
    NSMutableArray *spots;
    NSNumber *display_latitude;
    NSNumber *display_longitude;
}

@property (nonatomic, retain) NSMutableArray *spots;
@property (nonatomic, retain) NSNumber *display_latitude;
@property (nonatomic, retain) NSNumber *display_longitude;

+(NSArray *)createClustersFromSpots:(NSArray *)spots andMap:(MKMapView *)map;

@end

@interface ClusterGroup : NSObject {
    NSMutableArray *spots;
    NSNumber *east;
    NSNumber *west;
    NSNumber *north;
    NSNumber *south;
}

@property (nonatomic, retain) NSMutableArray *spots;
@property (nonatomic, retain) NSNumber *east;
@property (nonatomic, retain) NSNumber *west;
@property (nonatomic, retain) NSNumber *north;
@property (nonatomic, retain) NSNumber *south;

@end