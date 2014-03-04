//
//  EmailSpaceViewController.h
//  SpaceScout
//
//  Created by Patrick Michaud on 3/4/14.
//
//

#import <UIKit/UIKit.h>
#import "Space.h"

@interface EmailSpaceViewController : UIViewController <UITextViewDelegate, RESTFinished> {
    
}


@property (nonatomic, retain) Space *space;
@property (nonatomic, retain) REST *rest;
-(IBAction)sendEmail:(id)selector;
@end
