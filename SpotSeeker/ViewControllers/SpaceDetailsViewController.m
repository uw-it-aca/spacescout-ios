//
//  SpotDetailsViewController.m
//  SpotSeeker
//
//  Copyright 2012, 2013 UW Information Technology, University of Washington
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
@synthesize access_notes_height;
@synthesize overlay;
@synthesize favorites;

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

    BOOL has_labstats = [self.spot.extended_info objectForKey:@"auto_labstats_available"] != nil && [[self.spot.extended_info objectForKey:@"auto_labstats_total"] integerValue] > 0;
    
    int hours_cell_index = 1;
    int access_notes_index = 2;
    int labstats_cell_index = -1;
    
    if (has_labstats) {
        hours_cell_index++;
        access_notes_index++;
        labstats_cell_index += 2;
    }
    

    if (indexPath.section == 0 && indexPath.row == 0) {
        return [self heightOfImageCellInTable:tableView];
    }
    else if (indexPath.section == 0 && indexPath.row == hours_cell_index) {
        return [self heightOfHoursCellInTable:tableView];
    }
    else if (indexPath.section == 0 && indexPath.row == access_notes_index) {
        return [self heightOfAccessNotesCellInTable:tableView];
    }
    else if (indexPath.section == 2) {
        int offset = 0;
        if ([self.spot.extended_info objectForKey:@"access_notes"] != nil) {
            if (indexPath.row == offset) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"access_notes_cell"];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"access_notes_cell"];
                }
                if (self.access_notes_height != nil) {
                    return [self.access_notes_height floatValue] + 5;
                }
                
                UIWebView *display = (UIWebView *)[cell viewWithTag:100];
                [display loadHTMLString:[self.spot.extended_info objectForKey:@"access_notes"] baseURL:nil];
                NSInteger height = [[display stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] integerValue];
                
                return height + 20.0;
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
        
        CGFloat expected_height = [equipment_string boundingRectWithSize:CGSizeMake(type.frame.size.width, 500.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: type.font } context:nil].size.height;

       
        NSString *app_path = [[NSBundle mainBundle] bundlePath];
        NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
        NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
        
        float equipment_extra = [[plist_values objectForKey:@"equipment_cell_extra_height"] floatValue];
        
        float basic = cell.frame.size.height;
        float calculated = expected_height + equipment_extra;
        
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
    int base_number = 2;
    if (section == 0) {
        if ([self.spot.extended_info objectForKey:@"access_notes"] != nil || [self.spot.extended_info objectForKey:@"reservation_notes"] != nil) {
            base_number++;
        }
        if ([self.spot.extended_info objectForKey:@"auto_labstats_available"] != nil) {
            base_number++;
        }
        return base_number;
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
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([self.spot.latitude floatValue], [self.spot.longitude floatValue]);
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            [mapItem setName:self.spot.name];
            
            // Set the directions mode to "Walking"
            // Can use MKLaunchOptionsDirectionsModeDriving instead
            NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
            // Get the "Current User Location" MKMapItem
            MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
            // Pass the current location and destination map items to the Maps app
            // Set the direction mode in the launchOptions dictionary
            [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL has_labstats = [self.spot.extended_info objectForKey:@"auto_labstats_available"] != nil && [[self.spot.extended_info objectForKey:@"auto_labstats_total"] integerValue] > 0;

    int hours_cell_index = 1;
    int access_notes_index = 2;
    int labstats_cell_index = -1;
    
    if (has_labstats) {
        hours_cell_index++;
        access_notes_index++;
        labstats_cell_index += 2;
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        return [self cellForImageAndNameInTable:tableView];
    }
    else if (indexPath.section == 0 && indexPath.row == labstats_cell_index) {
        return [self cellForLabstatsInTable:tableView];
    }
    else if (indexPath.section == 0 && indexPath.row == hours_cell_index) {
        return [self cellForHoursInTable:tableView];
    }
    else if (indexPath.section == 0 && indexPath.row == access_notes_index) {
        return [self cellForAccessNotesInTable:tableView];
    }
    else if (indexPath.section == 1) {
        int attribute_offset = 0;
        if ([self.equipment_fields count] > 0) {
            attribute_offset = 1;
        }
        
        if (indexPath.row == 0 && attribute_offset) {
            return [self cellForEquipmentInTable:tableView];
        }
        else {
            return [self cellForEnvironmentInTable:tableView atOffset:attribute_offset andIndexPath:indexPath];
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
                
                UIWebView *notes = (UIWebView *)[cell viewWithTag:100];
                NSString *encoded = [[self.spot.extended_info objectForKey:@"access_notes"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
                encoded = [encoded stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
                encoded = [encoded stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
                
                NSString *app_path = [[NSBundle mainBundle] bundlePath];
                NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
                NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
                
                NSString *format =  [plist_values objectForKey:@"access_notes_wrapper_format"];
                NSString *final_notes = [NSString stringWithFormat:format, encoded];
                
                notes.delegate = self;
                [notes loadHTMLString:final_notes baseURL:nil];
                notes.frame = CGRectMake(notes.frame.origin.x, notes.frame.origin.y, notes.frame.size.width, [self.access_notes_height floatValue]);
                
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

#pragma mark -
#pragma mark cell heights

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1;
    }
    return 20.0;
}

-(CGFloat)heightOfImageCellInTable:(UITableView *)tableView {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"image_and_name"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"image_and_name"];
    }
    
    float baseline_height = cell.frame.size.height;
    
    UILabel *name_label = (UILabel *)[cell viewWithTag:1];
    
    // Only add height if this actually wraps
    
    CGRect expected = [self.spot.name boundingRectWithSize:CGSizeMake(name_label.frame.size.width, 500.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: name_label.font } context:nil];
    
    return baseline_height + expected.size.height - expected.size.height;
}

-(CGFloat)heightOfHoursCellInTable:(UITableView *)tableView {
    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];

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
    
    CGFloat expected_height = [spot_description boundingRectWithSize:CGSizeMake(description_label.frame.size.width, 500.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: description_label.font } context:nil].size.height;
    
    float hours_cell_extra = [[plist_values objectForKey:@"hours_cell_extra_height"] floatValue];
    
    UILabel *open_label = (UILabel *)[cell viewWithTag:50];
    float open_label_bottom = open_label.frame.origin.y + open_label.frame.size.height;
    
    return hours_height + expected_height + open_label_bottom + hours_cell_extra + location_header_size + location_padding;
}

-(CGFloat)heightOfAccessNotesCellInTable:(UITableView *)tableView {
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

#pragma mark -
#pragma mark cell formatting
-(UITableViewCell *)cellForImageAndNameInTable:(UITableView *)tableView {
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
    
    if ([self.spot isOpenNow]) {
        UIImageView *flag_view = (UIImageView *)[cell viewWithTag:50];
        flag_view.image = [UIImage imageNamed:@"flag_open"];
    }
    else {
        UIImageView *flag_view = (UIImageView *)[cell viewWithTag:50];
        flag_view.image = [UIImage imageNamed:@"flag_closed"];
    }
    
    UIButton *fav_button = (UIButton *)[cell viewWithTag:20];
    self.favorite_button = fav_button;
    if (spot.is_favorite) {
        [self.favorite_button setImage:[UIImage imageNamed:@"star_selected"] forState:UIControlStateNormal];
    }
    
    UIButton *spot_image_view = (UIButton *)[cell viewWithTag:4];
    
    
    if ([spot.image_urls count] == 0) {
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:10];
        spinner.hidden = YES;
        
    }
    
    UIPageControl *page_view = (UIPageControl *)[cell viewWithTag:9];
    page_view.numberOfPages = [spot.image_urls count];
    
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
    }
    else {
        UIImage *no_image = [UIImage imageNamed:@"placeholder_noImage_bw.png"];
        [self displaySpaceImage:no_image];
    }
    
    return cell;
}

-(UITableViewCell *)cellForLabstatsInTable:(UITableView *)tableView {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"labstats_cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"labstats_cell"];
    }
    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
    
    float avail_redtext_red_value = [[plist_values objectForKey:@"labstats_avail_redtext_red"] floatValue];
    float avail_redtext_green_value = [[plist_values objectForKey:@"labstats_avail_redtext_green"] floatValue];
    float avail_redtext_blue_value = [[plist_values objectForKey:@"labstats_avail_redtext_blue"] floatValue];
    
    UIColor *avail_redtext_color = [UIColor colorWithRed:avail_redtext_red_value / 255.0 green:avail_redtext_green_value / 255.0 blue:avail_redtext_blue_value / 255.0 alpha:1.0];
    
    float avail_greentext_red_value = [[plist_values objectForKey:@"labstats_avail_greentext_red"] floatValue];
    float avail_greentext_green_value = [[plist_values objectForKey:@"labstats_avail_greentext_green"] floatValue];
    float avail_greentext_blue_value = [[plist_values objectForKey:@"labstats_avail_greentext_blue"] floatValue];
    
    UIColor *avail_greentext_color = [UIColor colorWithRed:avail_greentext_red_value / 255.0 green:avail_greentext_green_value / 255.0 blue:avail_greentext_blue_value / 255.0 alpha:1.0];

    id raw_total_value = [spot.extended_info objectForKey:@"auto_labstats_total"];
    
    if (raw_total_value != nil && [raw_total_value integerValue] > 0) {
        UILabel *total = (UILabel *)[cell viewWithTag:32];
        total.text = raw_total_value;
        
        id raw_available_value = [spot.extended_info objectForKey:@"auto_labstats_available"];
        
        UILabel *available = (UILabel *)[cell viewWithTag:31];
        
        if (raw_available_value == nil || ![self.spot isOpenNow]) {
            available.text = @"--";
        }
        else {
            available.text = raw_available_value;
            if ([raw_available_value integerValue] == 0) {
                available.textColor = avail_redtext_color;
            }
            else {
                available.textColor = avail_greentext_color;
            }
        }
        
        CGFloat space_width = [@" " boundingRectWithSize:CGSizeMake(500.0, 500.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: available.font } context:nil].size.width;
        CGFloat of_width = [@"of" boundingRectWithSize:CGSizeMake(500.0, 500.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: available.font } context:nil].size.width;
        CGFloat available_width = [available.text boundingRectWithSize:CGSizeMake(500.0, 500.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: available.font } context:nil].size.height;
        CGFloat total_field_width = [total.text boundingRectWithSize:CGSizeMake(500.0, 500.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: total.font } context:nil].size.width;
        
        UILabel *of_label = (UILabel *)[cell viewWithTag:33];
        UILabel *available_now_label = (UILabel *)[cell viewWithTag:34];

        CGFloat starting_x = available.frame.origin.x;
        
        CGFloat of_label_left = starting_x + available_width + space_width;
        CGFloat total_left = of_label_left + of_width + space_width;
        CGFloat available_left = total_left + total_field_width + space_width;
        
        of_label.frame = CGRectMake(of_label_left, of_label.frame.origin.y, of_label.frame.size.width, of_label.frame.size.height);
        total.frame = CGRectMake(total_left, total.frame.origin.y, total.frame.size.width, total.frame.size.height);
        available_now_label.frame = CGRectMake(available_left, available_now_label.frame.origin.y, available_now_label.frame.size.width, available_now_label.frame.size.height);
        
    }
    else {
        
    }
    
    return cell;
}

-(UITableViewCell *)cellForHoursInTable:(UITableView *)tableView {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hours_cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hours_cell"];
    }
    
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
        
        CGFloat expected_height = [description.text boundingRectWithSize:CGSizeMake(description.frame.size.width, 500.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: description.font } context:nil].size.height;
        
        description.frame = CGRectMake(description.frame.origin.x, location_header_bottom, description.frame.size.width, expected_height);
        location_header.hidden = NO;
    }
    else {
        location_header.hidden = YES;
    }
    
    return cell;
}

-(UITableViewCell *)cellForAccessNotesInTable:(UITableView *)tableView {
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

-(UITableViewCell *)cellForEquipmentInTable:(UITableView *)tableView {
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
    
    CGFloat expected_height = [equipment_string boundingRectWithSize:CGSizeMake(type.frame.size.width, 500.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: type.font } context:nil].size.height;

    type.frame = CGRectMake(type.frame.origin.x, type.frame.origin.y, type.frame.size.width, expected_height);
    
    type.text = equipment_string;
    
    return cell;
}

-(UITableViewCell *)cellForEnvironmentInTable:(UITableView *)tableView atOffset:(int)attribute_offset andIndexPath:(NSIndexPath *)indexPath{
    
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

#pragma mark -
#pragma mark hours formatting


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
#pragma mark oauth login protocol

-(void) backButtonPressed:(id)sender {
}

-(void)loginComplete {
    [self.navigationController popViewControllerAnimated:YES];
    [self setServerFavoriteValue];
}

-(void)loginCancelled {
}

-(void) setServerFavoriteValue {
    if (!self.favorites) {
        self.favorites = [[Favorites alloc] init];
    }
    
    if (!self.overlay) {
        self.overlay = [[OverlayMessage alloc] init];
        [self.overlay addTo:self.view];
    }

    if (spot.is_favorite) {
        [self.favorite_button setImage:[UIImage imageNamed:@"star_unselected.png"] forState:UIControlStateNormal];
        spot.is_favorite = false;
        [self.favorites removeServerFavorite:spot];
        [self.overlay showOverlay:@"Removed" animateDisplay:YES afterShowBlock:^(void) {}];
        [self.overlay setImage: [UIImage imageNamed:@"GreenCheckmark"]];
    }
    else {
        [self.favorite_button setImage:[UIImage imageNamed:@"star_selected.png"] forState:UIControlStateNormal];
        spot.is_favorite = true;
        [self.favorites addServerFavorite:spot];
        [self.overlay showOverlay:@"Saved" animateDisplay:YES afterShowBlock:^(void) {}];
        [self.overlay setImage: [UIImage imageNamed:@"GreenCheckmark"]];
    }
    [self.overlay hideOverlayAfterDelay:1.0 animateHide:YES afterHideBlock:^(void){}];
    // This prevents a problem where going back to the list, then searching, in less than the FAVORITES_REFRESH_INTERVAL results
    // in the wrong value when coming back to the space
    [Space clearFavoritesCache];
}

#pragma mark -
#pragma mark button actions
- (IBAction) btnClickFavorite:(id)sender {
    if ([REST hasPersonalOAuthToken]) {
        [self setServerFavoriteValue];
    }
    else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
        
        OAuthLoginViewController *auth_vc = [storyboard instantiateViewControllerWithIdentifier:@"OAuth_Login"];
        auth_vc.delegate = self;
        auth_vc.title = @"SpaceScout";
        
        [self.navigationController pushViewController:auth_vc animated:YES];
    }
}


- (IBAction)btnClickReportProblem:(id)sender {
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    
    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"spotseeker.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
    
    NSString *to = [plist_values objectForKey:@"spotseeker_problem_email"];

    if (to == nil || [to isEqualToString:@""]) {
        to = @"spacescouthelp@uw.edu";
    }
    
    NSMutableArray *recipients = [[NSMutableArray alloc] init];
    [recipients insertObject:to atIndex:0];
    
    NSString *subject = [NSString stringWithFormat: NSLocalizedString(@"report_problem_email_subject", nil), self.spot.name];

    NSString *body = [NSString stringWithFormat: NSLocalizedString(@"report_problem_email_body", nil), self.spot.name, self.spot.building_name];

    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc]init];
    mailComposer.mailComposeDelegate = self;
    
    [mailComposer setToRecipients:recipients];
    [mailComposer setSubject:subject];
    [mailComposer setMessageBody:body isHTML:NO];
    [self presentViewController:mailComposer animated:YES completion:^(void) {}];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"image_view"]) {
        SpaceImagesScrollViewController *destination = (SpaceImagesScrollViewController *)[segue destinationViewController];
        destination.space = self.spot;
    }
    
    if ([[segue identifier] isEqualToString:@"map_display"]) {
        SingleSpaceMapViewController *destination = (SingleSpaceMapViewController *)[segue destinationViewController];
        destination.spot = self.spot;
    }
    
    if ([[segue identifier] isEqualToString:@"open_email_space"]) {
        EmailSpaceViewController *destination = (EmailSpaceViewController *)[segue destinationViewController];
        destination.space = self.spot;
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
    
   
    int row = 0;
    if(webView.tag == 2){// reservation_notes WebView

        if ([self.spot.extended_info objectForKey:@"access_notes"] != nil) {
            row = 1;
        }
        if (self.reservation_notes_height != nil) {
            return;
        }
        
        int height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] integerValue];
        self.reservation_notes_height = [NSNumber numberWithInt:height];
    }
    
    if(webView.tag == 100){//access_notes WebView

        if (self.access_notes_height != nil) {
            return;
        }
        
        int height_access = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] integerValue];
        self.access_notes_height = [NSNumber numberWithInt:height_access];
    }

    [self.table_view beginUpdates];
    [self.table_view reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
    [self.table_view endUpdates];
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
    self.screenName = @"Space Details View";
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

#pragma mark - mail compose delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result) {
        NSLog(@"Result : %d",result);
    }
    if (error) {
        NSLog(@"Error : %@",error);
    }
    
    [self dismissViewControllerAnimated:YES completion:^(void) {}];
}

@end
