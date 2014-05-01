//
//  MainListViewController.m
//  SpaceScout
//
//  Created by Patrick Michaud on 6/19/13.
//
//

#import "MainListViewController.h"

@interface MainListViewController ()

@end

@implementation MainListViewController

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
    
    if (self.current_spots.count < 1) {
        [self runSearch];
    }
    else {
        NSMutableArray *spaces_in_frame = [[NSMutableArray alloc] init];
        
        for (Space *space in self.current_spots) {
            float longitude = [space.longitude floatValue];
            float latitude = [space.latitude floatValue];
            CLLocationCoordinate2D space_coord = CLLocationCoordinate2DMake(latitude, longitude);

            if ([self isCoordinate:space_coord insideRegion:self.map_region]) {
                [spaces_in_frame addObject:space];
            }
        }
        
        self.spots_to_display = spaces_in_frame;
    }
}

// From https://gist.github.com/swissmanu/4943356
-(BOOL)isCoordinate:(CLLocationCoordinate2D)coordinate insideRegion:(MKCoordinateRegion)region {
    CLLocationCoordinate2D center = region.center;
    CLLocationCoordinate2D northWestCorner, southEastCorner;
    northWestCorner.latitude = center.latitude - (region.span.latitudeDelta / 2.0);
    northWestCorner.longitude = center.longitude - (region.span.longitudeDelta / 2.0);
    southEastCorner.latitude = center.latitude + (region.span.latitudeDelta / 2.0);
    southEastCorner.longitude = center.longitude + (region.span.longitudeDelta / 2.0);
    return(coordinate.latitude >= northWestCorner.latitude &&
           coordinate.latitude <= southEastCorner.latitude &&
           coordinate.longitude >= northWestCorner.longitude &&
           coordinate.longitude <= southEastCorner.longitude
           );
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
