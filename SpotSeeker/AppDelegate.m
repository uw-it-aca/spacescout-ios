//
//  AppDelegate.m
//  SpotSeeker
//
//  Copyright 2013 UW Information Technology, University of Washington
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

#import "AppDelegate.h"
#import "GAI.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize has_hidden_map_tooltip;
@synthesize user_location;
@synthesize search_preferences;
@synthesize last_preference_set_time;
@synthesize last_shown_offline_alert;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    has_hidden_map_tooltip = [NSNumber numberWithBool:false];
    NSString *app_path = [[NSBundle mainBundle] bundlePath];
    NSString *plist_path = [app_path stringByAppendingPathComponent:@"ui_magic_values.plist"];
    NSDictionary *plist_values = [NSDictionary dictionaryWithContentsOfFile:plist_path];
    
    float red_value = [[plist_values objectForKey:@"default_nav_button_color_red"] floatValue];
    float green_value = [[plist_values objectForKey:@"default_nav_button_color_green"] floatValue];
    float blue_value = [[plist_values objectForKey:@"default_nav_button_color_blue"] floatValue];

    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:red_value / 255.0 green:green_value / 255.0 blue:blue_value / 255.0 alpha:1.0]];
    
    // Register the preference defaults early.
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"enable_analytics"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"enable_analytics"]) {
        [[GAI sharedInstance] setOptOut:NO];
    } else {
        [[GAI sharedInstance] setOptOut:YES];
    }
    
    // register with the Notification Center in case someone changes settings
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(defaultsChanged:)
                   name:NSUserDefaultsDidChangeNotification
                 object:nil];
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = -1;
    // Optional: set debug to YES for extra debugging information.
    // TODO: don't forget to set this to NO for packaging
    [GAI sharedInstance].debug = NO;

    // Get GA tracking id if it exists
    NSString *ss_plist_path = [app_path stringByAppendingPathComponent:@"spotseeker.plist"];
    NSDictionary *ss_plist_values = [NSDictionary dictionaryWithContentsOfFile:ss_plist_path];
    NSString *tracking_id = [ss_plist_values objectForKey:@"ga_tracking_id"];

    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:tracking_id];

    return YES;
}

- (void)showNoNetworkAlert {
    if (self.last_shown_offline_alert != nil && [self.last_shown_offline_alert timeIntervalSinceNow] > -10) {
        return;
    }

    self.last_shown_offline_alert = [NSDate date];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no network connection title", nil) message:NSLocalizedString(@"no network connection message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"no network connection button", nil) otherButtonTitles:nil];
    [alert show];

}

- (void)defaultsChanged:(NSNotification *)notification {
    // Get the user defaults
    NSUserDefaults *defaults = (NSUserDefaults *)[notification object];
    
    if ([defaults boolForKey:@"enable_analytics"]) {
        [[GAI sharedInstance] setOptOut:NO];
    } else {
        [[GAI sharedInstance] setOptOut:YES];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[GAI sharedInstance] dispatch];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
