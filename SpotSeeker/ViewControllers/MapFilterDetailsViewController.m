//
//  MapFilterDetailsViewController.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapFilterDetailsViewController.h"

@interface MapFilterDetailsViewController ()

@end

@implementation MapFilterDetailsViewController

@synthesize filter;
@synthesize table_view;

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
    
    if ([[[[self.filter objectForKey:@"options"] objectAtIndex:indexPath.row] objectForKey:@"selected"] boolValue]) {
        current_cell.accessoryType = UITableViewCellAccessoryNone;
        [[[self.filter objectForKey:@"options"] objectAtIndex:indexPath.row] setObject:[NSNumber numberWithBool:FALSE] forKey:@"selected"];
    }
    else {
        current_cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [[[self.filter objectForKey:@"options"] objectAtIndex:indexPath.row] setObject:[NSNumber numberWithBool:TRUE] forKey:@"selected"];        
    }
}

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

@end
