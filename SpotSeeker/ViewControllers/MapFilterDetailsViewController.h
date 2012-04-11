//
//  MapFilterDetailsViewController.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapFilterDetailsViewController : UIViewController {
    NSMutableDictionary *filter;
}

//- (void) setFilter:(NSMutableDictionary *)filter;

@property (retain, nonatomic) NSMutableDictionary *filter;

@end
