//
//  SpaceImageScrollPageViewController.m
//  SpaceScout
//
//  Created by Patrick Michaud on 3/18/14.
//
//

#import "SpaceImageScrollPageViewController.h"

@interface SpaceImageScrollPageViewController () {
    NSUInteger page_number;
}

@end

@implementation SpaceImageScrollPageViewController

@synthesize rest;
@synthesize image_url;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadImageFromURL:(NSString *)_image_url {
    self.image_url = _image_url;
    
    if (!rest) {
        rest = [[REST alloc] init];
    }
    
    __weak ASIHTTPRequest *request = [rest getRequestForBlocksWithURL:image_url];
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
    
    [request setCompletionBlock:^{
        UIActivityIndicatorView *loading = (UIActivityIndicatorView *)[self.view viewWithTag:101];
        UIImageView *image_view = (UIImageView *)[self.view viewWithTag:100];
        loading.hidden = TRUE;
        UIImage *img = [[UIImage alloc] initWithData:[request responseData]];
        [image_view setContentMode:UIViewContentModeScaleAspectFit];
        [image_view setImage:img];
    }];
    
    [request startAsynchronous];
    
}

// load the view nib and initialize the pageNumber ivar
- (id)initWithPageNumber:(NSUInteger)page
{
    if (self = [super initWithNibName:@"SpaceImage" bundle:nil])
    {
        page_number = page;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
