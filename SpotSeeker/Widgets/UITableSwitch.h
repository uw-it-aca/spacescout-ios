//
//  UITableSwitch.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableSwitch : UISwitch {
    NSIndexPath *indexPath;
}

@property (nonatomic, retain) NSIndexPath *indexPath;

@end
