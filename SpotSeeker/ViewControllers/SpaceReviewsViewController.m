//
//  SpaceReviewsViewController.m
//  SpaceScout
//
//  Created by pmichaud on 4/1/14.
//
//

#import "SpaceReviewsViewController.h"

@implementation SpaceReviewsViewController

@synthesize reviews;
@synthesize rest;
@synthesize space;

NSString *STAR_SELECTED_IMAGE = @"star_selected";
NSString *STAR_UNSELECTED_IMAGE = @"star_unselected";
const float EXTRA_CELL_PADDING = 50.0;
const float EXTRA_REVIEW_PADDING = 20.0;

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
    
    [self drawHeader];
    
    self.rest = [[REST alloc] init];
    self.reviews = @[];
    
    NSString *reviews_url = [NSString stringWithFormat:@"/api/v1/spot/%@/reviews", self.space.remote_id];
    
    __weak ASIHTTPRequest *request = [rest getRequestForBlocksWithURL:reviews_url];
    
    [request setCompletionBlock:^{
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        if (200 != [request responseStatusCode]) {
            NSLog(@"Code: %i", [request responseStatusCode]);
            // show an error
        }

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss+'00:00'";

        self.reviews = [parser objectWithData:[request responseData]];
        for (NSMutableDictionary *review in reviews) {
            NSDate *date_obj = [dateFormatter dateFromString:[review objectForKey:@"date_submitted"]];
            [review setObject:date_obj forKey:@"date_object"];
        }
        [self.tableView reloadData];
    }];
    
    [request startAsynchronous];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [reviews count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"review_cell"];

    UILabel *author = (UILabel *)[cell viewWithTag:200];
    UILabel *date = (UILabel *)[cell viewWithTag:201];
    UITextView *review = (UITextView *)[cell viewWithTag:202];
    
    NSString *review_content = [[self.reviews objectAtIndex:indexPath.row] objectForKey:@"review"];
    
    CGSize bound = CGSizeMake(review.frame.size.width, CGFLOAT_MAX);
    CGRect frame_size = [review_content boundingRectWithSize:bound options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: review.font} context:nil];

    review.frame = CGRectMake(review.frame.origin.x, review.frame.origin.y, review.frame.size.width, frame_size.size.height + EXTRA_REVIEW_PADDING);

    review.text = review_content;
    author.text = [[self.reviews objectAtIndex:indexPath.row] objectForKey:@"reviewer"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    
    NSDate *date_obj = (NSDate *) [[self.reviews objectAtIndex:indexPath.row] objectForKey:@"date_object"];
    
    date.text = [dateFormatter stringFromDate:date_obj];

    int rating = [[[self.reviews objectAtIndex:indexPath.row] objectForKey:@"rating"] integerValue];
    for (int i = 1; i <= 5; i++) {
        UIImageView *star = (UIImageView *)[cell viewWithTag:100+i];
        if (rating < i) {
            [star setImage:[UIImage imageNamed:STAR_UNSELECTED_IMAGE]];
        }
        else {
            [star setImage:[UIImage imageNamed:STAR_SELECTED_IMAGE]];
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"review_cell"];
    UITextView *review = (UITextView *)[cell viewWithTag:202];

    CGFloat top = review.frame.origin.y;
    NSString *review_content = [[self.reviews objectAtIndex:indexPath.row] objectForKey:@"review"];


    CGSize bound = CGSizeMake(review.frame.size.width, CGFLOAT_MAX);
    CGRect frame_size = [review_content boundingRectWithSize:bound options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: review.font} context:nil];

    return top + frame_size.size.height + EXTRA_CELL_PADDING;
}

-(void)drawHeader {
    UILabel *space_name = (UILabel *)[self.view viewWithTag:600];
    space_name.text = self.space.name;

    UILabel *current_rating = (UILabel *)[self.view viewWithTag:601];
    current_rating.text = [NSString stringWithFormat:@"%@ stars (%@)", [self.space.extended_info valueForKey:@"aggregate_rating"], [self.space.extended_info valueForKey:@"review_count"]];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"write_review"]) {
        ReviewSpaceViewController *dest = (ReviewSpaceViewController *)[segue destinationViewController];
        dest.space = self.space;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
