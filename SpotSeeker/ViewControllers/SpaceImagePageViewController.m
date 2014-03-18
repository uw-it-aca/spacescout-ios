//
//  SpaceImagePageViewController.m
//  SpaceScout
//
//  Created by Patrick Michaud on 3/17/14.
//
//

#import "SpaceImagePageViewController.h"

@implementation SpaceImagePageViewController

@synthesize rest;
@synthesize space;
@synthesize current_page;

-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    for (UIViewController *vc in pendingViewControllers) {
        [self setImageFrameForPageContent:vc];

    }
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [self.space.image_urls count];
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    int page_number = ((SpaceImagePageContentViewController *)viewController).page_number;
    int next_page = page_number + 1;

    if (next_page >= [self.space.image_urls count]) {
        return nil;
    }

    return [self viewControllerForIndex:next_page];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    int page_number = ((SpaceImagePageContentViewController *)viewController).page_number;
    int next_page = page_number - 1;

    if (next_page < 0) {
        return nil;
    }
    
    return [self viewControllerForIndex:next_page];
}

-(UIViewController *)viewControllerForIndex:(int)index {
    SpaceImagePageContentViewController *vc = [[SpaceImagePageContentViewController alloc] init];

    vc.page_number = index;
    vc.view.backgroundColor = [UIColor blackColor];
    
    NSString *image_url = [space.image_urls objectAtIndex:index];

    if (!rest) {
        rest = [[REST alloc] init];
    }

    __weak ASIHTTPRequest *request = [rest getRequestForBlocksWithURL:image_url];
    UIImageView *image_view = [[UIImageView alloc] init];
    image_view.tag = 100;

    [vc.view setAutoresizesSubviews:YES];
    
    [vc.view addSubview:image_view];

    [self setImageFrameForPageContent:vc];
   
    [request setCompletionBlock:^{
        
        UIImage *img = [[UIImage alloc] initWithData:[request responseData]];
        [image_view setContentMode:UIViewContentModeScaleAspectFit];
        [image_view setImage:img];
    }];
    
    [request startAsynchronous];
    
    return vc;
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
    
    self.dataSource = self;
    self.delegate = self;
   
    self.view.backgroundColor = [UIColor blackColor];
    UIViewController *vc = [self viewControllerForIndex:0];
    self.current_page = (SpaceImagePageContentViewController *)vc;
    [self setImageFrameForPageContent:vc];
    

    NSArray *view_controllers = @[vc];
    [self setViewControllers:view_controllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {}];

    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    
}

-(BOOL)prefersStatusBarHidden {
    return TRUE;
}

-(void)viewDidDisappear:(BOOL)animated {
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(void)setImageFrameForPageContent:(UIViewController *)vc {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;

    UIImageView *img_view = (UIImageView *)[vc.view viewWithTag:100];
    if (UIDeviceOrientationIsPortrait(orientation)) {
        img_view.frame = vc.view.frame;
    }
    else {
        // Sometimes we get a frame that's rotated, sometimes we get a frame that's in portrait mode
        // so - just force this to be rotated.
        if (vc.view.frame.size.width < vc.view.frame.size.height) {
            img_view.frame = CGRectMake(0, 0, vc.view.frame.size.height, vc.view.frame.size.width);
            
        }
        else {
            img_view.frame = vc.view.frame;
        }
    }
    
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [self setImageFrameForPageContent:self.current_page];
    
    for (UIViewController *vc in self.viewControllers) {
        [self setImageFrameForPageContent:vc];
    }
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
