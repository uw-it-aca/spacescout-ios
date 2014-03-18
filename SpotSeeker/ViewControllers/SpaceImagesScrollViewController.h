//
//  SpaceImagesScrollViewController.h
//  SpaceScout
//
//  Created by Patrick Michaud on 3/18/14.
//
//

#import <UIKit/UIKit.h>
#import "Space.h"
#import "REST.h"
#import "SpaceImageScrollPageViewController.h"

@interface SpaceImagesScrollViewController : UIViewController <UIScrollViewDelegate> {
    
}

@property (nonatomic, retain) IBOutlet UIScrollView *scroll_view;
@property (nonatomic, retain) IBOutlet UIPageControl *page_control;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, retain) Space *space;
@property (nonatomic, retain) REST *rest;
@property (nonatomic) int showing_navigation;

@end
