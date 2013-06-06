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

#import "SpaceDetailsViewController.h"


@implementation SpaceDetailsViewController

@synthesize spot;
@synthesize capacity_label;
@synthesize favorite_button;
@synthesize favorite_spots;
@synthesize img_button_view;
@synthesize rest;
@synthesize config;
@synthesize equipment_fields;
@synthesize environment_fields;
@synthesize spot_image;
@synthesize footer;
@synthesize table_view;
@synthesize reservation_notes_height;
@synthesize image_count_label;

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
    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];

    if (indexPath.section == 0 && indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"image_and_name"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"image_and_name"];
        }
        
        float baseline_height = cell.frame.size.height;
        
        UILabel *name_label = (UILabel *)[cell viewWithTag:1];
        
        // Only add height if this actually wraps
        CGSize expected = [self.spot.name sizeWithFont:name_label.font constrainedToSize:CGSizeMake(name_label.frame.size.width, 500.0)  lineBreakMode:UILineBreakModeWordWrap];
        CGSize base_size = [@"A" sizeWithFont:name_label.font];
        
        return baseline_height + expected.height - base_size.height;
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hours_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hours_cell"];
        }
        
        NSMutableArray *display_hours = [[[HoursFormat alloc] init] displayLabelsForHours:spot.hours_available];
        UILabel *hours_label = (UILabel *)[cell viewWithTag:11];
        int hours_height = hours_label.frame.size.height * [display_hours count];
           
        UILabel *description_label = (UILabel *)[cell viewWithTag:100];
        
        float location_header_size = 0;
        float location_padding = 0;
        NSString *spot_description = [self.spot.extended_info objectForKey:@"location_description"];
        if (![spot_description isEqualToString:@""]) {
            UILabel *location_header_label = (UILabel *)[cell viewWithTag:51];
            location_header_size = location_header_label.frame.size.height;
                        
            location_padding = [[plist_values objectForKey:@"space_details_location_spacing"] floatValue];

        }
        CGSize expected = [spot_description sizeWithFont:description_label.font constrainedToSize:CGSizeMake(description_label.frame.size.width, 500.0)  lineBreakMode:description_label.lineBreakMode];

        NSString *app_path = [[NSBundle mainBundle] bundlePath];
        NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
        NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
        
        float hours_cell_extra = [[plist_values objectForKey:@"hours_cell_extra_height"] floatValue];

        UILabel *open_label = (UILabel *)[cell viewWithTag:50];
        float open_label_bottom = open_label.frame.origin.y + open_label.frame.size.height;
        
        return hours_height + expected.height + open_label_bottom + hours_cell_extra + location_header_size + location_padding;
    }
    else if (indexPath.section == 0 && indexPath.row == 2) {
        NSString *access_notes = [self.spot.extended_info objectForKey:@"access_notes"];
        NSString *reservation_notes = [self.spot.extended_info objectForKey:@"reservation_notes"];
        
        NSString *cell_id;

        if (access_notes != nil && reservation_notes != nil) {
            cell_id = @"notes_bubble_cell_both";
        }
        else if (access_notes != nil) {
            cell_id = @"notes_bubble_cell_access";
        }
        else {
            cell_id = @"notes_bubble_cell_reservations";
        }
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        }
        
        return cell.bounds.size.height - 1.0;
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
                
                if (self.reservation_notes_height != nil) {
                    return [self.reservation_notes_height floatValue] + 5;
                }
                
                UIWebView *display = (UIWebView *)[cell viewWithTag:2];
                [display loadHTMLString:[self.spot.extended_info objectForKey:@"reservation_notes"] baseURL:nil];
                NSInteger height = [[display stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] integerValue];
                
                return height + 20.0;
            }
            offset++;
        }
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"map_view_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"map_view_cell"];
        }
        return cell.frame.size.height;
    }
    else if (indexPath.section == 1 && indexPath.row == 0 && [self.equipment_fields count] > 0) {
        NSMutableArray *display_fields = [[NSMutableArray alloc] init];
        for (NSMutableDictionary *field in self.equipment_fields) {
            NSString *lang_key = [NSString stringWithFormat:@"Space equipment %@", [field objectForKey:@"attribute"]];
            NSString *display_value = NSLocalizedString(lang_key, nil);
            
            [display_fields addObject:display_value];
        }
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"equipment_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"equipment_cell"];
        }    
        
        UILabel *type = (UILabel *)[cell viewWithTag:1];
        
        NSString *equipment_string = [display_fields componentsJoinedByString:@", "];
        CGSize expected = [equipment_string sizeWithFont:type.font constrainedToSize:CGSizeMake(type.frame.size.width, 500.0) lineBreakMode:type.lineBreakMode];

        NSString *app_path = [[NSBundle mainBundle] bundlePath];
        NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
        NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
        
        float equipment_extra = [[plist_values objectForKey:@"equipment_cell_extra_height"] floatValue];
        
        float basic = cell.frame.size.height;
        float calculated = expected.height + equipment_extra;
        
        if (basic > calculated) {
            return basic;
        }
        return calculated;        
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

-(IBAction)btnClickImageBrowserOpen:(id)sender {
    if ([self.spot.image_urls count] > 0) {
        [self performSegueWithIdentifier:@"image_view" sender:self];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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

            // Google Maps fails to give good directions for spotnames with (,),& in them
            NSString *fixed_spotname = [self.spot.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            fixed_spotname = [fixed_spotname stringByReplacingOccurrencesOfString:@"(" withString:@""];
            fixed_spotname = [fixed_spotname stringByReplacingOccurrencesOfString:@")" withString:@""];
            fixed_spotname = [fixed_spotname stringByReplacingOccurrencesOfString:@"&" withString:@""];

            NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=Current+Location&daddr=%f,%f%%20(%@)", [self.spot.latitude floatValue], [self.spot.longitude floatValue], fixed_spotname];
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
        [spot_name sizeToFit];
        
        UILabel *spot_type = (UILabel *)[cell viewWithTag:2];
        
        NSMutableArray *type_names = [[NSMutableArray alloc] init];
        for (NSString *type in self.spot.type) {
            NSString *string_key = [NSString stringWithFormat:@"Space type %@", type];
                                
            NSString *type_name = NSLocalizedString(string_key, nil);
            [type_names addObject:type_name];
        }
        NSString *type_and_capacity = [type_names componentsJoinedByString:@", "];
        
        if (spot.capacity > 0) {
            type_and_capacity = [NSString stringWithFormat:@"%@, seats %@", type_and_capacity, spot.capacity];
        }
        [spot_type setText: type_and_capacity];
        
        UILabel *capacity = (UILabel *)[cell viewWithTag:3];
        NSString *capacity_string = [[NSString alloc] initWithFormat:@"%@", self.spot.capacity];
        [capacity setText: capacity_string];
        
        if ([self isOpenNow:self.spot.hours_available]) {
            UIImageView *flag_view = (UIImageView *)[cell viewWithTag:50];
            flag_view.image = [UIImage imageNamed:@"flag_open"];
        }
        else {
            UIImageView *flag_view = (UIImageView *)[cell viewWithTag:50];
            flag_view.image = [UIImage imageNamed:@"flag_closed"];            
        }

        UIButton *fav_button = (UIButton *)[cell viewWithTag:20];
        self.favorite_button = fav_button;
        if ([Favorites isFavorite:spot]) {
            [self.favorite_button setImage:[UIImage imageNamed:@"star_selected.png"] forState:UIControlStateNormal];        
        }
        
        UIButton *spot_image_view = (UIButton *)[cell viewWithTag:4];
        
        
        if ([spot.image_urls count] == 0) {
            UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:10];
            spinner.hidden = YES;
            
        }
        self.image_count_label = (UILabel *)[cell viewWithTag:9];
        if ([spot.image_urls count] < 2) {
            self.image_count_label.hidden = YES;
        }

        self.img_button_view = spot_image_view;
 
        if ([spot.image_urls count]) {
            [[spot_image_view imageView] setContentMode: UIViewContentModeScaleAspectFill];
            spot_image_view.contentMode = UIViewContentModeScaleToFill;

            if (self.spot_image) {
                UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:10];
                spinner.hidden = YES;
                [self displaySpaceImage:self.spot_image];
            }
            else {
                NSString *image_url = [spot.image_urls objectAtIndex:0];
                if (self.rest == nil) {
                    REST *_rest = [[REST alloc] init];
                    _rest.delegate = self;
                    self.rest = _rest;
                }
                [self.rest getURL:image_url];
            }
            UILabel *image_count = (UILabel *)[cell viewWithTag:9];
            image_count.text = [NSString stringWithFormat:@"1 of %i", [spot.image_urls count]];
            
        }
        else {
            UIImage *no_image = [UIImage imageNamed:@"placeholder_noImage_bw.png"];
            [self displaySpaceImage:no_image];
        }
        
        return cell;
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hours_cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hours_cell"];
        }
        
#pragma mark labstats
        NSLog(@"Available: %@, Total: %@", [spot.extended_info objectForKey:@"auto_labstats_available"], [spot.extended_info objectForKey:@"auto_labstats_total"]);
        
        id raw_total_value = [spot.extended_info objectForKey:@"auto_labstats_total"];

        if (raw_total_value != nil && [raw_total_value integerValue] > 0) {
            UILabel *total = (UILabel *)[cell viewWithTag:32];
            total.text = raw_total_value;

            id raw_available_value = [spot.extended_info objectForKey:@"auto_labstats_available"];

            UILabel *available = (UILabel *)[cell viewWithTag:31];

            if (raw_available_value == nil) {
                available.text = @"--";
            }
            else {
                available.text = raw_available_value;
                if ([raw_available_value integerValue] == 0) {
                    available.textColor = [UIColor redColor];
                }
            }
        }
        else {
            
        }
        
#pragma mark hours
        
        NSMutableArray *display_hours = [[[HoursFormat alloc] init] displayLabelsForHours:spot.hours_available];
        
        for (int index = 0; index < [display_hours count]; index++) {
            UILabel *hours_label = (UILabel *)[cell viewWithTag:(index + 11)];
            hours_label.text = [display_hours objectAtIndex:index];
            hours_label.hidden = NO;
        }
                
        for (int index = [display_hours count]; index <= 7; index++) {
            UILabel *hours_label = (UILabel *)[cell viewWithTag:(index + 11)];
            hours_label.hidden = YES;
            hours_label.text = @"";            
        }
        
        UILabel *description = (UILabel *)[cell viewWithTag:100];
        description.text = [self.spot.extended_info objectForKey:@"location_description"];
        
        UILabel *location_header = (UILabel *)[cell viewWithTag:51];

        if (![description.text isEqualToString:@""]) {
            UILabel *bottom_hours = (UILabel *)[cell viewWithTag:[display_hours count] + 11 - 1];
            float hours_bottom = bottom_hours.frame.origin.y + bottom_hours.frame.size.height;    
            
            location_header.frame = CGRectMake(location_header.frame.origin.x, hours_bottom, location_header.frame.size.width, location_header.frame.size.height);
            
            float location_header_bottom = location_header.frame.origin.y + location_header.frame.size.height;
            
            CGSize expected = [description.text sizeWithFont:description.font constrainedToSize:CGSizeMake(description.frame.size.width, 500.0)  lineBreakMode:description.lineBreakMode];
            
            description.frame = CGRectMake(description.frame.origin.x, location_header_bottom, description.frame.size.width, expected.height);
            location_header.hidden = NO;
        }
        else {
            location_header.hidden = YES;
        }
        
        return cell;
    }
    else if (indexPath.section == 0 && indexPath.row == 2) {
        NSString *access_notes = [self.spot.extended_info objectForKey:@"access_notes"];
        NSString *reservation_notes = [self.spot.extended_info objectForKey:@"reservation_notes"];

        NSString *cell_id;
        if (access_notes != nil && reservation_notes != nil) {
            cell_id = @"notes_bubble_cell_both";
        }
        else if (access_notes != nil) {
            cell_id = @"notes_bubble_cell_access";
        }
        else {
            cell_id = @"notes_bubble_cell_reservations";
        }
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        }
                
        if ([self.spot.extended_info objectForKey:@"reservation_notes"] != nil) {
            UILabel *reservations_label = (UILabel *)[cell viewWithTag:31];
            if ([[self.spot.extended_info objectForKey:@"reservable"] isEqualToString:@"reservations"]) {
                reservations_label.text = NSLocalizedString(@"Space reservable required", nil);
            }
            else {
                reservations_label.text = NSLocalizedString(@"Space reservable optional", nil);
            }

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
                NSString *lang_key = [NSString stringWithFormat:@"Space equipment %@", [field objectForKey:@"attribute"]];
                NSString *display_value = NSLocalizedString(lang_key, nil);

                [display_fields addObject:display_value];
            }
            
            UILabel *type = (UILabel *)[cell viewWithTag:1];

            NSString *equipment_string = [display_fields componentsJoinedByString:@", "];
            CGSize expected = [equipment_string sizeWithFont:type.font constrainedToSize:CGSizeMake(type.frame.size.width, 500.0) lineBreakMode:type.lineBreakMode];
            
            type.frame = CGRectMake(type.frame.origin.x, type.frame.origin.y, type.frame.size.width, expected.height);
            
            type.text = equipment_string;

            return cell;
        }
        else {
            
            NSDictionary *attribute = [self.environment_fields objectAtIndex:indexPath.row - attribute_offset];
            NSString *attribute_key = [attribute objectForKey:@"attribute"];
            NSString *attribute_value = [self.spot.extended_info objectForKey:attribute_key];

            NSString *lang_key = [NSString stringWithFormat:@"Space environment %@ %@", attribute_key, attribute_value];
            NSString *display_value = NSLocalizedString(lang_key, nil);

            NSString *cell_type = @"environment_cell";
            NSString *label_lang_key = [NSString stringWithFormat:@"Space environment label %@", attribute_key];
            NSString *label_display_value = NSLocalizedString(label_lang_key, nil);
            
            if (![label_display_value isEqualToString:@""]) {
                cell_type = @"environment_cell_with_label";
            }
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_type];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_type];
            }
            
           
            UILabel *value = (UILabel *)[cell viewWithTag:2];
            
            UIImageView *icon_view = (UIImageView *)[cell viewWithTag:1];
            
            if ([attribute_key isEqualToString:@"food_nearby"]) {
                UIImage *icon = [UIImage imageNamed:@"cafe.png"];
                icon_view.image = icon;
            }
            else if ([attribute_key isEqualToString:@"noise_level"]) {
                UIImage *icon = [UIImage imageNamed:@"noise.png"];
                icon_view.image = icon;
            }
            else if ([attribute_key isEqualToString:@"has_natural_light"]) {
                UIImage *icon = [UIImage imageNamed:@"lighting.png"];
                icon_view.image = icon;                
            }
            
            if (![label_display_value isEqualToString:@""]) {
                UILabel *label = (UILabel *)[cell viewWithTag:3];
                label.text = label_display_value;                                        
            }
            
            [value setText: display_value];
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
                               
                notes.text = [self.spot.extended_info objectForKey:@"access_notes"];
                return cell;
            }
            offset++;
        }
        if ([self.spot.extended_info objectForKey:@"reservation_notes"] != nil) {
            
            if (indexPath.row == offset) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reservation_notes_cell"];
                if (cell == nil) {
                    NSLog(@"Cell is nil");
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reservation_notes_cell"];
                }    
                UIWebView *notes = (UIWebView *)[cell viewWithTag:2];
                                
                NSString *encoded = [[self.spot.extended_info objectForKey:@"reservation_notes"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
                encoded = [encoded stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
                encoded = [encoded stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];

                NSString *app_path = [[NSBundle mainBundle] bundlePath];
                NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
                NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
                
                NSString *format =  [plist_values objectForKey:@"reservation_notes_wrapper_format"];
                NSString *final_notes = [NSString stringWithFormat:format, encoded];
                
                notes.delegate = self;
                [notes loadHTMLString:final_notes baseURL:nil];
                notes.frame = CGRectMake(notes.frame.origin.x, notes.frame.origin.y, notes.frame.size.width, [self.reservation_notes_height floatValue]);

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

-(float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"DetailsTableFooter"
                                                          owner:self
                                                        options:nil];
        
        
        UIView *_footer = [nibViews objectAtIndex: 0];

        return _footer.frame.size.height;
    }
    return 0.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 2) {
        if (self.footer) {
            return self.footer;
        }
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"DetailsTableFooter"
                                                          owner:self
                                                        options:nil];
        
        
        UIView *_footer = [nibViews objectAtIndex: 0];
        
        UILabel *modification_label = (UILabel *)[_footer viewWithTag:1];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yyyy";
        
        modification_label.text = [NSString stringWithFormat:NSLocalizedString(@"spot details modification date", nil), [dateFormatter stringFromDate:spot.modifified_date]];
        
        UIButton *report_problem = (UIButton *)[_footer viewWithTag:2];        
        [report_problem addTarget:self action:@selector(btnClickReportProblem:) forControlEvents:UIControlEventTouchUpInside];

        self.footer = _footer;
    }
    return nil;
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

-(void)displaySpaceImage:(UIImage *)image {
    self.spot_image = image;
    
    self.img_button_view.contentMode = UIViewContentModeScaleAspectFill;
    self.img_button_view.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.img_button_view.imageView.image = image;

    [self.img_button_view setImage:image forState:UIControlStateNormal];
    [self.img_button_view setImage:image forState:UIControlStateHighlighted];
    [self.img_button_view setImage:image forState:UIControlStateSelected];
    
    self.img_button_view.hidden = NO;
    
    if ([spot.image_urls count] >= 2) {
        self.image_count_label.hidden = NO;
    }
    
}

-(void)requestFromREST:(ASIHTTPRequest *)request {
    if ([request responseStatusCode] == 200) {
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[self.view viewWithTag:10];
        spinner.hidden = TRUE;
        UIImage *img = [[UIImage alloc] initWithData:[request responseData]];
        [self displaySpaceImage:img];

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

- (IBAction)btnClickReportProblem:(id)sender {
    UIApplication *app = [UIApplication sharedApplication];  
    
    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"spotseeker.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
    
    NSString *to = [plist_values objectForKey:@"spotseeker_problem_email"];

    if (to == nil || [to isEqualToString:@""]) {
        to = @"spacescouthelp@uw.edu";
    }
    NSString *subject = [NSString stringWithFormat: NSLocalizedString(@"report_problem_email_subject", nil), self.spot.name];
    subject = [subject stringByReplacingOccurrencesOfString:@"&" withString:@"and"];

    NSString *body = [NSString stringWithFormat: NSLocalizedString(@"report_problem_email_body", nil), self.spot.name, self.spot.building_name];
    body = [body stringByReplacingOccurrencesOfString:@"&" withString:@"and"];

    NSString *url = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@&body=%@", [to stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [subject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [app openURL:[NSURL URLWithString:url]];  
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"image_view"]) {
        SpaceImagesViewController *destination = (SpaceImagesViewController *)[segue destinationViewController];
        destination.spot = self.spot;
    }
    
    if ([[segue identifier] isEqualToString:@"map_display"]) {
        SingleSpaceMapViewController *destination = (SingleSpaceMapViewController *)[segue destinationViewController];
        destination.spot = self.spot;
    }
}

#pragma mark -
#pragma mark web view methods


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}


-(void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.reservation_notes_height != nil) {
        return;
    }
    
    int height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] integerValue];
    self.reservation_notes_height = [NSNumber numberWithInt:height];
    int row = 0;
    if ([self.spot.extended_info objectForKey:@"access_notes"] != nil) {
        row = 1;
    }
    
    [self.table_view reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
    
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
	// Do any additional setup after loading the view.
    self.trackedViewName = @"Space Details View";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
    //    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
