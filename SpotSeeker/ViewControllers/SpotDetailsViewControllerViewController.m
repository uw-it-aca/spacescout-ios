//
//  SpotDetailsViewControllerViewController.m
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

#import "SpotDetailsViewControllerViewController.h"


@implementation SpotDetailsViewControllerViewController

@synthesize spot;
@synthesize capacity_label;
@synthesize favorite_button;
@synthesize favorite_spots;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) showDataForSpot {
//    [self setTitle:[spot name]];
    
    
    [self.capacity_label setText:[spot capacity]];
    
    // Read in favorites
    self.favorite_spots = [[NSMutableDictionary alloc] init];
    
    id is_favorite = [self.favorite_spots objectForKey:spot.id];
      
    if (is_favorite != nil) {
        [self.favorite_button setImage:[UIImage imageNamed:@"star_selected.png"] forState:UIControlStateNormal];        
    }

}

- (IBAction) btnClickFavorite:(id)sender {
    NSString *is_favorite = [self.favorite_spots objectForKey:self.spot.id];
    
    if (is_favorite == nil) {
        [self.favorite_button setImage:[UIImage imageNamed:@"star_selected.png"] forState:UIControlStateNormal];
        [self.favorite_spots setObject:@"1" forKey:self.spot.id];
       
    }
    else {
        [self.favorite_button setImage:[UIImage imageNamed:@"star_unselected.png"] forState:UIControlStateNormal];
        [self.favorite_spots removeObjectForKey:self.spot.id];
    }
    
    // Write out favorites
}

- (void)viewDidLoad
{
    UIImage *image = [UIImage imageNamed:@"cat_named_spot.jpg"];    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    self.navigationItem.titleView = imageView;

    [super viewDidLoad];
    [self showDataForSpot];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    self.navigationItem.titleView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

@end
