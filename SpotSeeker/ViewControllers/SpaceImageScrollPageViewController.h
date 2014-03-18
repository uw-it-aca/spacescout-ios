//
//  SpaceImageScrollPageViewController.h
//  SpaceScout
//
//  Created by Patrick Michaud on 3/18/14.
//
//

#import <UIKit/UIKit.h>
#import "REST.h"

@interface SpaceImageScrollPageViewController : UIViewController {
}

- (id)initWithPageNumber:(NSUInteger)page;
@property (nonatomic, retain) NSString *image_url;
@property (nonatomic, retain) REST *rest;

-(void)loadImageFromURL:(NSString *)image_url;

@end
