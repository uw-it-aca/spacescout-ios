//
//  SpaceImagesScrollViewController.m
//  SpaceScout
//
//  Created by Patrick Michaud on 3/18/14.
//
//

#import "SpaceImagesScrollViewController.h"

@implementation SpaceImagesScrollViewController

@synthesize scroll_view;
@synthesize rest;
@synthesize space;
@synthesize viewControllers;
@synthesize page_control;
@synthesize showing_navigation;

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
    
    NSUInteger numberPages = self.space.image_urls.count;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numberPages; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    // a page is the width of the scroll view
    self.scroll_view.pagingEnabled = YES;
    self.scroll_view.contentSize =
    CGSizeMake(CGRectGetWidth(self.scroll_view.frame) * numberPages, CGRectGetHeight(self.scroll_view.frame));
    self.scroll_view.showsHorizontalScrollIndicator = NO;
    self.scroll_view.showsVerticalScrollIndicator = NO;
    self.scroll_view.scrollsToTop = NO;
    self.scroll_view.delegate = self;
    
    self.page_control.numberOfPages = numberPages;
    self.page_control.currentPage = 0;
    
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    //
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    
    self.showing_navigation = TRUE;
    UITapGestureRecognizer *single_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [single_tap setNumberOfTapsRequired:1];
    [single_tap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:single_tap];
    
}

-(void)tapAction:(id)selector {
    UINavigationBar *nav_bar = (UINavigationBar *)[self.view viewWithTag:400];
    if (showing_navigation) {
        [UIView animateWithDuration:0.5 animations:^(void) {
            nav_bar.alpha = 0.0;
        }];
    }
    else {
        [UIView animateWithDuration:0.5 animations:^(void) {
            nav_bar.alpha = 1.0;
        }];
    }
    
    self.showing_navigation = !self.showing_navigation;
}

-(IBAction)closeImageViewer:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

-(BOOL)prefersStatusBarHidden {
    return TRUE;
}

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= self.space.image_urls.count)
        return;
    
    // replace the placeholder if necessary
    SpaceImageScrollPageViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[SpaceImageScrollPageViewController alloc] initWithPageNumber:page];
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = self.scroll_view.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        [self addChildViewController:controller];
        [self.scroll_view addSubview:controller.view];
        [controller didMoveToParentViewController:self];
        
        [controller loadImageFromURL:[self.space.image_urls objectAtIndex:page]];
    }
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // remove all the subviews from our scrollview
    for (UIView *view in self.scroll_view.subviews)
    {
        [view removeFromSuperview];
    }
    
    NSUInteger numPages = self.space.image_urls.count;
    
    // adjust the contentSize (larger or smaller) depending on the orientation
    self.scroll_view.contentSize =
    CGSizeMake(CGRectGetWidth(self.scroll_view.frame) * numPages, CGRectGetHeight(self.scroll_view.frame));
    
    // clear out and reload our pages
    self.viewControllers = nil;
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numPages; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    [self loadScrollViewWithPage:self.page_control.currentPage - 1];
    [self loadScrollViewWithPage:self.page_control.currentPage];
    [self loadScrollViewWithPage:self.page_control.currentPage + 1];
    [self gotoPage:NO]; // remain at the same page (don't animate)
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(self.scroll_view.frame);
    NSUInteger page = floor((self.scroll_view.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.page_control.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
}


- (void)gotoPage:(BOOL)animated
{
    NSInteger page = self.page_control.currentPage;
  
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect bounds = self.scroll_view.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [self.scroll_view scrollRectToVisible:bounds animated:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
