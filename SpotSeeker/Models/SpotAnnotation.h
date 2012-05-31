//
//  SpotAnnotation.h
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
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SpotAnnotation : NSObject <MKAnnotation> {
    NSString *title;
    NSNumber *cluster_index;
    NSString *subtitle;
    NSArray *spots;
    CLLocationCoordinate2D coordinate; 
}

-(NSString *)getLookupKey;

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle; 
@property (nonatomic,retain) NSNumber *cluster_index;
@property (nonatomic,retain) NSArray *spots;
@end
