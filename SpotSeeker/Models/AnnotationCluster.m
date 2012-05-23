//
//  AnnotationClusters.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AnnotationCluster.h"


@implementation AnnotationCluster
@synthesize spots;
@synthesize display_latitude;
@synthesize display_longitude;

+(NSArray *)createClustersFromSpots:(NSArray *)input_spots andMap:(MKMapView *)map_view {
    NSMutableArray *cluster_groups = [[NSMutableArray alloc] init];
    for (int index = 0; index < input_spots.count; index++) {
        Spot *spot = [input_spots objectAtIndex:index];
        
        ClusterGroup *test_group = [AnnotationCluster createClusterGroupForSpot:spot andMapView:map_view];
        
        NSArray *values = [AnnotationCluster clusterGroup:test_group intersectsWithClusters:cluster_groups onMapView:map_view];
        NSArray *intersections = [values objectAtIndex:0];
        NSArray *misses = [values objectAtIndex:1];
        
        // Rebuild the cluster groups from misses, then add either the new cluter group, or the merged one
        [cluster_groups removeAllObjects];
        [cluster_groups addObjectsFromArray:misses];
       
        if (intersections.count > 0) {
            NSMutableArray *to_merge = [[NSMutableArray alloc] initWithArray:intersections];
            ClusterGroup *merged = [AnnotationCluster mergeClusterGroups:to_merge];
            [cluster_groups addObject:merged];
        }
    }
    
    NSMutableArray *final_clusters = [[NSMutableArray alloc] init];
    for (int index = 0; index < cluster_groups.count; index++) {
        NSArray *from_group = [AnnotationCluster createClustersForGroup:[cluster_groups objectAtIndex:index]];
        [final_clusters addObjectsFromArray:from_group];
    }
    
    return final_clusters;
}

+(NSNumber *)pixelsPerLongitudeForMapView:(MKMapView *)map_view {
    return [NSNumber numberWithFloat: map_view.frame.size.height / map_view.region.span.longitudeDelta];
}

+(NSNumber *)pixelsPerLatitudeForMapView:(MKMapView *)map_view {
    return [NSNumber numberWithFloat: map_view.frame.size.width / map_view.region.span.latitudeDelta];
}

+(NSArray *)clusterGroup:(ClusterGroup *)test_group intersectsWithClusters:(NSArray *)cluster_groups onMapView:(MKMapView *)map_view {
    NSMutableArray *intersections = [[NSMutableArray alloc] init];
    NSMutableArray *misses = [[NSMutableArray alloc] init];

    bool has_intersection = false;
    for (int index = 0; index < cluster_groups.count; index++) {
        ClusterGroup *cluster = [cluster_groups objectAtIndex:index];
        if ([AnnotationCluster clusterGroup:(ClusterGroup *)test_group intersectsWithClusterGroup:(ClusterGroup *)cluster]) {
            has_intersection = true;
            [intersections addObject:cluster];
        }
        else {
            [misses addObject:cluster];
        }
    }
    
    if (has_intersection) {
        [intersections addObject:test_group];
    }
    else {
        [misses addObject:test_group];
    }
    
    return [[NSArray alloc] initWithObjects:intersections, misses, nil];
}

+(BOOL)clusterGroup:(ClusterGroup *)test_group intersectsWithClusterGroup:(ClusterGroup *)cluster_group {
    if ([test_group.east floatValue] < [cluster_group.west floatValue]) {
        return false;
    }
    if ([test_group.west floatValue] > [cluster_group.east floatValue]) {
        return false;
    }
    if ([test_group.north floatValue] < [cluster_group.south floatValue]) {
        return false;
    }
    if ([test_group.south floatValue] > [cluster_group.north floatValue]) {
        return false;
    }
    // There's an extra limit, that only spots in the same building intersect.
    Spot *test_spot = [test_group.spots objectAtIndex:0];
    Spot *cluster_spot = [cluster_group.spots objectAtIndex:0];
    
    if (test_spot.building_name != cluster_spot.building_name) {
        return false;
    }
    return true;
}
            
+(ClusterGroup *)mergeClusterGroups:(NSArray *)cluster_groups {
    float min_west = 360;
    float max_north = -360;
    float min_south = 360;
    float max_east = -360;
    
    NSMutableArray *all_spots = [[NSMutableArray alloc] init];
    for (int index = 0; index < cluster_groups.count; index++) {
        ClusterGroup *group = [cluster_groups objectAtIndex:index];
        [all_spots addObjectsFromArray:group.spots];
        
        if ([group.south floatValue] < min_south) {
            min_south = [group.south floatValue];
        }
        if ([group.north floatValue] > max_north) {
            max_north = [group.north floatValue];
        }
        if ([group.east floatValue] > max_east) {
            max_east = [group.east floatValue];
        }
        if ([group.west floatValue] < min_west) {
            min_west = [group.west floatValue];
        }
    }
    
    ClusterGroup *joined = [[ClusterGroup alloc] init];
    joined.spots = all_spots;
    joined.east = [NSNumber numberWithFloat:max_east];
    joined.west = [NSNumber numberWithFloat:min_west];
    joined.north = [NSNumber numberWithFloat:max_north];
    joined.south = [NSNumber numberWithFloat:min_south];
    
    return joined;
}

+(ClusterGroup *)createClusterGroupForSpot:(Spot *)spot andMapView:(MKMapView *)map_view {
    UIImage *sample_pin = [UIImage imageNamed:@"01.png"];
    float width = sample_pin.size.width;
    float height = sample_pin.size.height;
    
    ClusterGroup *group = [[ClusterGroup alloc] init];
    NSMutableArray *spots = [[NSMutableArray alloc] init];
    [spots addObject:spot];
    group.spots = spots;
    
    group.west = [NSNumber numberWithFloat:[spot.longitude floatValue] - ((width / 2) / [[AnnotationCluster pixelsPerLongitudeForMapView:map_view] floatValue])];
    group.east = [NSNumber numberWithFloat:[spot.longitude floatValue] + ((width / 2) / [[AnnotationCluster pixelsPerLongitudeForMapView:map_view] floatValue])];

    group.south = [NSNumber numberWithFloat:[spot.latitude floatValue] - ((height / 2) / [[AnnotationCluster pixelsPerLatitudeForMapView:map_view] floatValue])];
    group.north = [NSNumber numberWithFloat:[spot.latitude floatValue] + ((height / 2) / [[AnnotationCluster pixelsPerLatitudeForMapView:map_view] floatValue])];

    return group;    
}

+(NSArray *)createClustersForGroup:(ClusterGroup *)group {
    NSMutableArray *final_clusters = [[NSMutableArray alloc] init];
    
    AnnotationCluster *all_of_it = [[AnnotationCluster alloc] init];
    NSMutableArray *all_spots = [NSArray arrayWithArray:group.spots];
    
    float total_latitude;
    float total_longitude;
    
    for (int index = 0; index < group.spots.count; index++) {
        Spot *spot = [group.spots objectAtIndex:index];
        total_latitude += [spot.latitude floatValue];
        total_longitude += [spot.longitude floatValue];
    }
    
    all_of_it.spots = all_spots;
    all_of_it.display_latitude = [NSNumber numberWithFloat:total_latitude / group.spots.count];
    all_of_it.display_longitude = [NSNumber numberWithFloat:total_longitude / group.spots.count];
    
    [final_clusters addObject:all_of_it];
    
    return final_clusters;
}



@end


@implementation ClusterGroup

@synthesize spots;
@synthesize east;
@synthesize west;
@synthesize north;
@synthesize south;

@end
