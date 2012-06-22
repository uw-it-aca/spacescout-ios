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

#pragma mark -
#pragma mark table control methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"Environment";
    }
    if (section == 2) {
        return @"Getting Here";
    }
    return @"";
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"image_and_name"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"image_and_name"];
        }
        
        if ([self.spot.image_urls count]) {
            return cell.frame.size.height;
        }
        return 120;
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hours_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hours_cell"];
        }
        
        NSMutableArray *display_hours = [[[HoursFormat alloc] init] displayLabelsForHours:spot.hours_available];
        UILabel *hours_label = (UILabel *)[cell viewWithTag:11];
        int hours_height = hours_label.frame.size.height;
        
        int unneeded = 7 - [display_hours count];
        
        return cell.frame.size.height - (unneeded * hours_height);
    }
    else if (indexPath.section == 0 && indexPath.row == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notes_bubble_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notes_bubble_cell"];
        }
        
        float base_size = cell.frame.size.height;

        if ([self.spot.extended_info objectForKey:@"access_notes"] == nil) {
            UIView *notes = (UIView *)[cell viewWithTag:21];
            base_size -= notes.frame.size.height - 10;
        }

        if ([self.spot.extended_info objectForKey:@"reservation_notes"] == nil) {
            UIView *notes = (UIView *)[cell viewWithTag:22];
            base_size -= notes.frame.size.height - 10;
        }

        return base_size;
    }
    else if (indexPath.section == 2) {
        int offset = 0;
        if ([self.spot.extended_info objectForKey:@"access_notes"] != nil) {
            if (indexPath.row == offset) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"access_notes_cell"];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"access_notes_cell"];
                }
                UILabel *display = (UILabel *)[cell viewWithTag:2];

                CGSize expected = [[self.spot.extended_info objectForKey:@"access_notes"] sizeWithFont:display.font constrainedToSize:CGSizeMake(display.frame.size.width, 500.0)  lineBreakMode:display.lineBreakMode];

                return expected.height + 20.0;
            }
            offset++;
        }
        
        if ([self.spot.extended_info objectForKey:@"reservation_notes"] != nil) {
            if (indexPath.row == offset) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reservation_notes_cell"];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reservation_notes_cell"];
                }
                UILabel *display = (UILabel *)[cell viewWithTag:2];

                CGSize expected = [[self.spot.extended_info objectForKey:@"reservation_notes"] sizeWithFont:display.font constrainedToSize:CGSizeMake(display.frame.size.width, 500.0)  lineBreakMode:display.lineBreakMode];
                
                return expected.height + 20.0;
            }
            offset++;
        }
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"map_view_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"map_view_cell"];
        }
        return cell.frame.size.height;
    }

    // Right now only the image/name cell and hours cell need a custom height, so the choice in cell here is arbitrary
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"map_view_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"map_view_cell"];
        }
        return cell.frame.size.height;
   
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if ([self.spot.extended_info objectForKey:@"access_notes"] != nil || [self.spot.extended_info objectForKey:@"reservation_notes"] != nil) {
            return 3;
        }
        return 2;
    }
    if (section == 1) {
        int count = [self.environment_fields count];
        if ([self.equipment_fields count] > 0) {
            count++;
        }
        return count;
    }
    else if (section == 2) {
        int count = 2;
        if ([self.spot.extended_info objectForKey:@"access_notes"] != nil) {
            count++;
        }
        if ([self.spot.extended_info objectForKey:@"reservation_notes"] != nil) {
            count++;
        }
        
        return count;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        if ([self.spot.image_urls count] > 0) {
            [self performSegueWithIdentifier:@"image_view" sender:self];
        }
    }
    if (indexPath.section == 2) {
        int offset = 0;
        if ([self.spot.extended_info objectForKey:@"access_notes"] != nil) {
            offset++;
        }
        if ([self.spot.extended_info objectForKey:@"reservation_notes"] != nil) {
            offset++;
        }
   
        if (indexPath.row - offset == 0) {
            // ...
        }
        else if (indexPath.row - offset == 1) {
            UIApplication *app = [UIApplication sharedApplication];  
            NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=Current+Location&daddr=%f,%f%%20(%@)", [self.spot.latitude floatValue], [self.spot.longitude floatValue], [self.spot.name stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy]];
            [app openURL:[NSURL URLWithString:url]];  
        }
    }
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
        
        NSString *type_and_capacity = self.spot.type;
        
        if (spot.capacity > 0) {
            type_and_capacity = [NSString stringWithFormat:@"%@, seats %@", type_and_capacity, spot.capacity];
        }
        [spot_type setText: type_and_capacity];
        
        UILabel *capacity = (UILabel *)[cell viewWithTag:3];
        NSString *capacity_string = [[NSString alloc] initWithFormat:@"%@", self.spot.capacity];
        [capacity setText: capacity_string];
        
        if (![self isOpenNow:self.spot.hours_available]) {
            UILabel *open_now = (UILabel *)[cell viewWithTag:5];
            open_now.text = @"CLOSED";
            open_now.textColor = [UIColor blackColor];
            open_now.backgroundColor = [UIColor redColor];
        }

        UIButton *fav_button = (UIButton *)[cell viewWithTag:20];
        self.favorite_button = fav_button;
        
        UIImageView *spot_image = (UIImageView *)[cell viewWithTag:4];
        
        if ([spot.image_urls count] == 0) {
            UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:10];
            spinner.hidden = YES;
        }
        
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
        
        NSMutableArray *display_hours = [[[HoursFormat alloc] init] displayLabelsForHours:spot.hours_available];
        
        for (int index = 0; index < [display_hours count]; index++) {
            UILabel *hours_label = (UILabel *)[cell viewWithTag:(index + 11)];
            hours_label.text = [display_hours objectAtIndex:index];
        }
        
        for (int index = [display_hours count]; index <= 7; index++) {
            UILabel *hours_label = (UILabel *)[cell viewWithTag:(index + 11)];
            hours_label.text = @"";            
        }
        
        return cell;
    }
    else if (indexPath.section == 0 && indexPath.row == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notes_bubble_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notes_bubble_cell"];
        }
        
        if ([self.spot.extended_info objectForKey:@"access_notes"] == nil) {
            UIView *reservation_notes = (UIView *)[cell viewWithTag:22];

            UIView *notes = (UIView *)[cell viewWithTag:21];
            notes.hidden = YES;
            
            // Need to move the reservation notes up
            reservation_notes.frame = CGRectMake(reservation_notes.frame.origin.x, notes.frame.origin.y, reservation_notes.frame.size.width, reservation_notes.frame.size.height);
            UIView *wrapper = (UIView *)[cell viewWithTag:20];
            wrapper.frame = CGRectMake(wrapper.frame.origin.x, wrapper.frame.origin.y, wrapper.frame.size.width, reservation_notes.frame.size.height + 4);

        }
        
        if ([self.spot.extended_info objectForKey:@"reservation_notes"] == nil) {
            UIView *access_notes = (UIView *)[cell viewWithTag:21];
            UIView *notes = (UIView *)[cell viewWithTag:22];
            notes.hidden = YES;
            UIView *wrapper = (UIView *)[cell viewWithTag:20];
            
            wrapper.frame = CGRectMake(wrapper.frame.origin.x, wrapper.frame.origin.y, wrapper.frame.size.width, access_notes.frame.size.height + 4);
        }

        return cell;
    }
    else if (indexPath.section == 1) {
        int attribute_offset = 0;
        if ([self.equipment_fields count] > 0) {
            attribute_offset = 1;
        }
        
        if (indexPath.row == 0 && attribute_offset) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"equipment_cell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"equipment_cell"];
            }    
            
            NSMutableArray *display_fields = [[NSMutableArray alloc] init];
            for (NSMutableDictionary *field in self.equipment_fields) {
                [display_fields addObject:[field objectForKey:@"display"]];
            }
            
            UILabel *type = (UILabel *)[cell viewWithTag:1];
            type.text = [display_fields componentsJoinedByString:@", "];

            return cell;
        }
        else {        
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"environment_cell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"environment_cell"];
            }
                                   
            UILabel *value = (UILabel *)[cell viewWithTag:2];
            
            NSDictionary *attribute = [self.environment_fields objectAtIndex:indexPath.row - attribute_offset];
            NSString *attribute_key = [attribute objectForKey:@"attribute"];
            NSString *attribute_value = [self.spot.extended_info objectForKey:attribute_key];

            
            UIImageView *icon_view = (UIImageView *)[cell viewWithTag:1];
            
            if ([attribute_key isEqualToString:@"food_nearby"]) {
                UIImage *icon = [UIImage imageNamed:@"cafe.png"];
                icon_view.image = icon;
            }
            else if ([attribute_key isEqualToString:@"noise_level"]) {
                UIImage *icon = [UIImage imageNamed:@"noise.png"];
                icon_view.image = icon;
            }
            
            [value setText: attribute_value];
            return cell;
        }
    }
    else if (indexPath.section == 2)  {
        int offset = 0;
        if ([self.spot.extended_info objectForKey:@"access_notes"] != nil) {
            
            if (indexPath.row == offset) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"access_notes_cell"];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"access_notes_cell"];
                }    
                
                UILabel *notes = (UILabel *)[cell viewWithTag:2];
                
                CGSize expected = [[self.spot.extended_info objectForKey:@"access_notes"] sizeWithFont:notes.font constrainedToSize:CGSizeMake(notes.frame.size.width, 500.0)  lineBreakMode:notes.lineBreakMode];

                notes.frame = CGRectMake(notes.frame.origin.x, notes.frame.origin.y, notes.frame.size.width, expected.height);
                
                notes.text = [self.spot.extended_info objectForKey:@"access_notes"];
                return cell;
            }
            offset++;
        }
        if ([self.spot.extended_info objectForKey:@"reservation_notes"] != nil) {
            
            if (indexPath.row == offset) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reservation_notes_cell"];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reservation_notes_cell"];
                }    
                UILabel *notes = (UILabel *)[cell viewWithTag:2];
 
                CGSize expected = [[self.spot.extended_info objectForKey:@"reservation_notes"] sizeWithFont:notes.font constrainedToSize:CGSizeMake(notes.frame.size.width, 500.0)  lineBreakMode:notes.lineBreakMode];
                
                notes.frame = CGRectMake(notes.frame.origin.x, notes.frame.origin.y, notes.frame.size.width, expected.height);
                
                notes.text = [self.spot.extended_info objectForKey:@"reservation_notes"];

                return cell;
            }
            offset++;
        }
        
        if (indexPath.row - offset == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"map_view_cell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"map_view_cell"];
            }    
            return cell;
        }

        if (indexPath.row - offset == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"google_maps_cell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"google_maps_cell"];
            }    
            return cell;
        }

        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"equipment_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"equipment_cell"];
        }    
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

#pragma mark -
#pragma mark hours formatting
     
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

#pragma mark -
#pragma mark image methods

-(void)requestFromREST:(ASIHTTPRequest *)request {
    if ([request responseStatusCode] == 200) {
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[self.view viewWithTag:10];
        spinner.hidden = TRUE;
        UIImage *img = [[UIImage alloc] initWithData:[request responseData]];
        [self.img_view setImage:img];
    }
}

#pragma mark -
#pragma mark equipment and environment

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

#pragma mark -
#pragma mark button actions
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


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"image_view"]) {
        SpotImagesViewController *destination = (SpotImagesViewController *)[segue destinationViewController];
        destination.spot = self.spot;
    }
    
    if ([[segue identifier] isEqualToString:@"map_display"]) {
        SingleSpotMapViewController *destination = (SingleSpotMapViewController *)[segue destinationViewController];
        destination.spot = self.spot;
    }
}
#pragma mark -
#pragma mark setup

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


@end
