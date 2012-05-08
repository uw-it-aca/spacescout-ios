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
@synthesize equipment_fields;
@synthesize environment_fields;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"Environment";
    }
    if (section == 2) {
        return @"Equipment";
    }
    return @"";
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"image_and_name"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"image_and_name"];
        }
        
        return cell.frame.size.height;
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hours_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hours_cell"];
        }
        
        return cell.frame.size.height;
    }

    // Right now only the image/name cell and hours cell need a custom height, so the choice in cell here is arbitrary
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"environment_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"environment_cell"];
        }
        return cell.frame.size.height;
                
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    if (section == 1) {
        return [self.environment_fields count];
    }
    else if (section == 2) {
        return [self.equipment_fields count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {       
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"image_and_name"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"image_and_name"];
        }
        
        UILabel *spot_name = (UILabel *)[cell viewWithTag:1];
        [spot_name setText:self.spot.name];
        
        UILabel *spot_type = (UILabel *)[cell viewWithTag:2];
        [spot_type setText: self.spot.type];
        
        UILabel *capacity = (UILabel *)[cell viewWithTag:3];
        NSString *capacity_string = [[NSString alloc] initWithFormat:@"%@", self.spot.capacity];
        [capacity setText: capacity_string];
        
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
    else if (indexPath.section == 0 && indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hours_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hours_cell"];
        }
        
        NSMutableArray *display_hours = [self formatHours:self.spot.hours_available];
        
        for (int index = 0; index < [display_hours count]; index++) {
            UILabel *hours_label = (UILabel *)[cell viewWithTag:(index + 11)];
            hours_label.text = [display_hours objectAtIndex:index];
        }
        
        if (![self isOpenNow:self.spot.hours_available]) {
            UILabel *open_now = (UILabel *)[cell viewWithTag:2];
            open_now.hidden = true;
        }
        return cell;
    }
    else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"environment_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"environment_cell"];
        }
        UILabel *type = (UILabel *)[cell viewWithTag:1];
        UILabel *value = (UILabel *)[cell viewWithTag:2];
        
        NSDictionary *attribute = [self.environment_fields objectAtIndex:indexPath.row];
        NSString *attribute_key = [attribute objectForKey:@"attribute"];
        NSString *attribute_value = [self.spot.extended_info objectForKey:attribute_key];
        
        [type setText: [attribute objectForKey:@"display"]];
        [value setText: attribute_value];
        
        return cell;
    }
    else if (indexPath.section == 2)  {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"equipment_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"equipment_cell"];
        }    
        NSDictionary *equipment_type = [self.equipment_fields objectAtIndex:indexPath.row];
        UILabel *type = (UILabel *)[cell viewWithTag:1];
        [type setText: [equipment_type objectForKey:@"display"]];
        return cell;
    }
    // This fallback should never be reached
    else {
        NSLog(@"Invalid index path section: %i", indexPath.section);
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"equipment_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"equipment_cell"];
        }    
        UILabel *type = (UILabel *)[cell viewWithTag:1];
        [type setText: @""];
        return cell;
        
    }
    
}

-(NSMutableArray *)formatHours:(NSMutableDictionary *)hours_available {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    [results addObject:[self formatDayHours:[hours_available objectForKey:@"monday"]]];
    [results addObject:[self formatDayHours:[hours_available objectForKey:@"tuesday"]]];
    [results addObject:[self formatDayHours:[hours_available objectForKey:@"wednesday"]]];
    [results addObject:[self formatDayHours:[hours_available objectForKey:@"thursday"]]];
    [results addObject:[self formatDayHours:[hours_available objectForKey:@"friday"]]];
    [results addObject:[self formatDayHours:[hours_available objectForKey:@"saturday"]]];
    [results addObject:[self formatDayHours:[hours_available objectForKey:@"sunday"]]];
     
    return results;
}

-(NSString *)formatDayHours:(NSMutableArray *)windows {
    NSMutableArray *windows_as_text = [[NSMutableArray alloc] init];
    
    for (NSArray *window in windows) {
        NSDateComponents *start = [window objectAtIndex:0];
        NSDateComponents *end = [window objectAtIndex:1];
    
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"h:mm a"];
        
        NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
        NSDate *start_date = [cal dateFromComponents:start];
        NSDate *end_date = [cal dateFromComponents:end];

        [windows_as_text addObject:[[NSString alloc] initWithFormat:@"%@-%@", [df stringFromDate:start_date], [df stringFromDate:end_date]]];
        
    }
    
    return [windows_as_text componentsJoinedByString:@", "];
}
     
-(BOOL)isOpenNow:(NSMutableDictionary *)hours_available {
    NSDate *now = [NSDate date];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:now];

    NSArray *day_lookup = [[NSArray alloc] initWithObjects:@"", @"sunday", @"monday", @"tuesday", @"wednesday", @"thursday", @"friday", @"saturday", nil];

    NSMutableArray *windows = [hours_available objectForKey:[day_lookup objectAtIndex:[components weekday]]];
       
    for (NSMutableArray *window in windows) {
        NSDateComponents *start = [window objectAtIndex:0];
        NSDateComponents *end   = [window objectAtIndex:1];

        [components setHour:[start hour]];
        [components setMinute:[start minute]];
        
        NSDate *start_cmp = [calendar dateFromComponents:components];

        [components setHour:[end hour]];
        [components setMinute:[end minute]];
        
        NSDate *end_cmp = [calendar dateFromComponents:components];

        // If the start time is before or equal to now, and the end time is after or equal to now, we're open
        if (([start_cmp compare:now] != NSOrderedDescending) && ([end_cmp compare:now] != NSOrderedAscending)) {
            return true;   
        }
        
    }

    return false;
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

    self.equipment_fields = [[NSMutableArray alloc] init];
    
    NSArray *equipment_types = [self.config objectForKey:@"equipment"];
    for (NSDictionary *type in equipment_types) {
        NSString *attribute = [type objectForKey:@"attribute"];
        NSString *show_if   = [type objectForKey:@"show_if"];
        
        NSString *value = [self.spot.extended_info objectForKey:attribute];
        if (value != nil && [value isEqual:show_if]) {
            [self.equipment_fields addObject:type];
        }
    }

    self.environment_fields = [[NSMutableArray alloc] init];
    
    NSArray *environment_types = [self.config objectForKey:@"environment"];
    for (NSDictionary *attribute in environment_types) {
        NSString *attribute_key = [attribute objectForKey:@"attribute"];
        NSString *attribute_value = [self.spot.extended_info objectForKey:attribute_key];

        if (attribute_value != nil && ![attribute_value isEqualToString:@""]) {
            [self.environment_fields addObject:attribute];
        }
    }
    
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