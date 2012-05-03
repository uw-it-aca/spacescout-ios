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

#import "SpotDetailsViewController.h"


@implementation SpotDetailsViewController

@synthesize spot;
@synthesize capacity_label;
@synthesize favorite_button;
@synthesize favorite_spots;
@synthesize img_view;
@synthesize rest;
@synthesize config;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return @"Environment";
    }
    if (section == 3) {
        return @"Equipment";
    }
    return @"";
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"environment_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"environment_cell"];
        }
        return cell.frame.size.height;
    }
    
    if (indexPath.section == 3) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"equipment_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"equipment_cell"];
        }    
        return cell.frame.size.height;
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"image_and_name"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"image_and_name"];
    }

    return cell.frame.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2) {
        return [[self.config objectForKey:@"environment"] count];
    }
    if (section == 3) {
        NSArray *equipment_types = [self.config objectForKey:@"equipment"];
        NSInteger row_count = 0;
        for (NSDictionary *type in equipment_types) {
            NSString *attribute = [type objectForKey:@"attribute"];
            NSString *show_if   = [type objectForKey:@"show_if"];

            NSString *value = [self.spot.extended_info objectForKey:attribute];
            if (value != nil && [value isEqual:show_if]) {
                row_count ++;
            }
        }
        return row_count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"environment_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"environment_cell"];
        }
        UILabel *type = (UILabel *)[cell viewWithTag:1];
        UILabel *value = (UILabel *)[cell viewWithTag:2];
        
        [type setText: @"Surfaces"];
        [value setText: @"Large table"];
        return cell;
    }
    
    if (indexPath.section == 3) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"equipment_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"equipment_cell"];
        }    
        UILabel *type = (UILabel *)[cell viewWithTag:1];
        [type setText: @"Whiteboards"];
        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"image_and_name"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"image_and_name"];
    }
    
    UILabel *spot_name = (UILabel *)[cell viewWithTag:1];
    [spot_name setText:self.spot.name];
    
    UIImageView *spot_image = (UIImageView *)[cell viewWithTag:4];

    
    if (self.img_view == nil) {
        self.img_view = spot_image;
        if ([spot.image_urls count]) {
            NSString *image_url = [spot.image_urls objectAtIndex:0];
            REST *_rest = [[REST alloc] init];
            _rest.delegate = self;
            [_rest getURL:image_url];
            self.rest = _rest;
        }
    }
    
    return cell;
}




-(void)requestFromREST:(ASIHTTPRequest *)request {
    if ([request responseStatusCode] == 200) {
        UIImage *img = [[UIImage alloc] initWithData:[request responseData]];
        [self.img_view setImage:img];
    }
}

- (IBAction) btnClickFavorite:(id)sender {
   
   
    if ([Favorites isFavorite:spot]) {
        [self.favorite_button setImage:[UIImage imageNamed:@"star_unselected.png"] forState:UIControlStateNormal];
        [Favorites removeFavorite:spot];     
    }
    else {
        [self.favorite_button setImage:[UIImage imageNamed:@"star_selected.png"] forState:UIControlStateNormal];
        [Favorites addFavorite:spot];
    }
    
}

-(void)detailConfiguration:(NSDictionary *)_config {
    self.config = _config;
}

- (void)viewDidLoad
{
    DisplayOptions *options = [[DisplayOptions alloc] init];
    options.delegate = self;
    [options loadOptions];
    
    /*
    UIImage *image = [UIImage imageNamed:@"cat_named_spot.jpg"];    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    self.navigationItem.titleView = imageView;
     */
    [super viewDidLoad];
    
    if ([Favorites isFavorite:spot]) {
        [self.favorite_button setImage:[UIImage imageNamed:@"star_selected.png"] forState:UIControlStateNormal];        
    }

    self.title = spot.name;
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    self.navigationItem.titleView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

@end
