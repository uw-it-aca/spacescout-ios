//
//  SpaceReviewsViewController.h
//  SpaceScout
//
//  Created by pmichaud on 4/1/14.
//
//

#import "ViewController.h"
#import "ReviewSpaceViewController.h"
#import "REST.h"
#import "Space.h"

@interface SpaceReviewsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
    
}

@property (nonatomic, retain) REST *rest;
@property (nonatomic, retain) Space *space;
@property (nonatomic, retain) NSArray *reviews;
@property (nonatomic) BOOL loading;

@end

