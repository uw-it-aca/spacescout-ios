//
//  SpaceImagePageViewController.h
//  SpaceScout
//
//  Created by Patrick Michaud on 3/17/14.
//
//

#import <UIKit/UIKit.h>
#import "REST.h"
#import "Space.h"
#import "SpaceImagePageContentViewController.h"

@interface SpaceImagePageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate> {
    
}

@property (nonatomic, retain) Space *space;
@property (nonatomic, retain) REST *rest;
@property (nonatomic, retain) SpaceImagePageContentViewController *current_page;

@end
