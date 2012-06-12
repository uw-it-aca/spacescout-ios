//
//  MapFilterDetailsViewController.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapFilterDetailsViewController.h"

@implementation MapFilterDetailsViewController

@synthesize filter;
@synthesize table_view;
@synthesize screen_header;
@synthesize screen_subheader;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *screen_title = [self.filter objectForKey:@"screen_title"];
    self.title = screen_title;
    
    int view_height = 0;
    
    NSString *screen_header_text = [self.filter objectForKey:@"screen_header"];
    if (screen_header_text != nil) {
        self.screen_header.text = screen_header_text;
        view_height += self.screen_header.frame.size.height;
        // this is somewhat arbitrary padding
        view_height += 10;
    }
    else {
        self.screen_header.hidden = YES;
    }

    NSString *screen_subheader_text = [self.filter objectForKey:@"screen_subheader"];

    if (screen_subheader_text != nil) {
        self.screen_subheader.text = screen_subheader_text;
        CGRect frame = screen_subheader.frame;

        CGSize expected = [screen_subheader_text sizeWithFont:screen_subheader.font constrainedToSize:CGSizeMake(frame.size.width, 500.0)  lineBreakMode:screen_subheader.lineBreakMode];
        
        frame.size.height = expected.height;
        screen_subheader.frame = frame;
        
        view_height += frame.size.height;
        // this is somewhat arbitrary padding
        view_height += 10;

    }
    else {
        self.screen_subheader.hidden = YES;
    }

    [self.table_view.tableHeaderView setFrame:CGRectMake(0.0, 0.0, 320.0, view_height)];
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark table methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.filter objectForKey:@"options"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"detail_cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *filter_label = (UILabel *)[cell viewWithTag:1];
    filter_label.text = [[[self.filter objectForKey:@"options"] objectAtIndex:indexPath.row] objectForKey:@"title"];

    if ([[[[self.filter objectForKey:@"options"] objectAtIndex:indexPath.row] objectForKey:@"selected"] boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;    
    }
    
    return cell;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    UITableViewCell *current_cell = [self.table_view cellForRowAtIndexPath:indexPath];
    NSMutableDictionary *option = [[self.filter objectForKey:@"options"] objectAtIndex:indexPath.row];
    
    if ([option objectForKey:@"clear_all"]) {
        for (int index = 0; index < [[self.filter objectForKey:@"options"] count]; index++) {
            NSMutableDictionary *opt = [[self.filter objectForKey:@"options"] objectAtIndex:index];
            [opt setObject:[NSNumber numberWithBool:FALSE] forKey:@"selected"];
            NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
            UITableViewCell *cell = [self.table_view cellForRowAtIndexPath:path];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        [current_cell setAccessoryType:UITableViewCellAccessoryCheckmark];        
    }
    else {
        for (int index = 0; index < [[self.filter objectForKey:@"options"] count]; index++) {
            NSMutableDictionary *opt = [[self.filter objectForKey:@"options"] objectAtIndex:index];
            if ([opt objectForKey:@"clear_all"]) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
                UITableViewCell *cell = [self.table_view cellForRowAtIndexPath:path];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
        }
        if ([[option objectForKey:@"selected"] boolValue]) {
            current_cell.accessoryType = UITableViewCellAccessoryNone;
            [option setObject:[NSNumber numberWithBool:FALSE] forKey:@"selected"];
        }
        else {
            current_cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [option setObject:[NSNumber numberWithBool:TRUE] forKey:@"selected"];        
        }
    }
}

@end
