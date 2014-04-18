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
const float EXTRA_CELL_PADDING = 25.0;
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
            NSLog(@"Body: %@", [request responseString]);
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
        if (self.reviews.count == 0) {
            self.tableView.scrollEnabled = FALSE;
        }
    }];
    
    [request startAsynchronous];
    
    UIButton *write_review = (UIButton *)[self.view viewWithTag:603];
    write_review.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    
    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
    
    float red_value = [[plist_values objectForKey:@"default_nav_button_color_red"] floatValue];
    float green_value = [[plist_values objectForKey:@"default_nav_button_color_green"] floatValue];
    float blue_value = [[plist_values objectForKey:@"default_nav_button_color_blue"] floatValue];
    
    UIColor *border_color = [UIColor colorWithRed:red_value / 255.0 green:green_value / 255.0 blue:blue_value / 255.0 alpha:1.0];
    
    write_review.layer.borderWidth = 1.0;
    write_review.layer.borderColor = border_color.CGColor;
    write_review.layer.cornerRadius = 3.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return 1 if there are no reviews, so we can show the no reviews cell
    NSInteger count = [reviews count];
    if (count > 0) {
        return count;
    }
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.reviews.count == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"no_reviews"];
        return cell;
    }
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

    NSInteger rating = [[[self.reviews objectAtIndex:indexPath.row] objectForKey:@"rating"] integerValue];
    NSString *img_name = [NSString stringWithFormat:@"StarRating-small_%li_fill.png", (long)rating];

    UIImageView *stars = (UIImageView *)[cell viewWithTag:100];
    [stars setImage:[UIImage imageNamed:img_name]];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.reviews.count == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"no_reviews"];
        return cell.frame.size.height;
    }
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

    // Decision on Apr/11/2014 - round up rating to int star value
    int aggregate_rating = 0;
    int review_count = 0;
    if ([self.space.extended_info valueForKey:@"review_count"]) {
        aggregate_rating = ceilf([[self.space.extended_info valueForKey:@"aggregate_rating"] floatValue]);
        review_count = [[self.space.extended_info valueForKey:@"review_count"] intValue];
    }
    
    NSString *img_name = [NSString stringWithFormat:@"StarRating-small_%i_fill.png", aggregate_rating];

    UIImageView *rating_display = (UIImageView *)[self.view viewWithTag:602];
    rating_display.image = [UIImage imageNamed:img_name];
    
    UILabel *current_rating = (UILabel *)[self.view viewWithTag:601];
    current_rating.text = [NSString stringWithFormat:@"(%i)", review_count];
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
