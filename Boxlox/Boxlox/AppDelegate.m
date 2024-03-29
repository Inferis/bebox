//
//  AppDelegate.m
//  Boxlox
//
//  Created by Tom Adriaenssen on 28/06/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "AppDelegate.h"
#import "IIViewDeckController.h"
#import "ListViewController.h"
#import "MapViewController.h"
#import "PadViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"
#import "BoxLocator.h"
#import "UIColor+Hex.h"
#import "TestFlight.h"

@implementation AppDelegate

- (void)finishLaunchingWithOptions:(NSDictionary *)launchOptions {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if !DEBUG
        [TestFlight takeOff:@"95c7c2a7e1a1929c69c4f452f3b85108_MjQyNjIwMTItMDctMDMgMTc6MzU6NTQuNTc0NzYw"];
#endif
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        if ([CLLocationManager locationServicesEnabled]) {
            _boxLocator = [[BoxLocator alloc] init];
        }

        UIViewController* rootViewController;
        
        if (IsIPad()) {
            PadViewController* padViewController = [[PadViewController alloc] initWithNibName:nil bundle:nil];
            rootViewController = padViewController;
        }
        else {
            ListViewController* listViewController = [[ListViewController alloc] initWithNibName:nil bundle:nil];
            MapViewController* mapViewController = [[MapViewController alloc] initWithNibName:nil bundle:nil];
            mapViewController.boxMapDelegate = listViewController;
            listViewController.boxSelectionDelegate = mapViewController;

            IIViewDeckController* deckController = [[IIViewDeckController alloc] initWithCenterViewController:listViewController leftViewController:mapViewController];
            deckController.leftLedge = 0;
            [deckController openLeftView];
            rootViewController = deckController;
        }
        
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"titlebg.png"] resizableImageWithCapInsets:UIEdgeInsetsZero] forBarMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"back-hi.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        self.window.rootViewController = navigationController;

        // Override point for customization after application launch.
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
    });
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self finishLaunchingWithOptions:(NSDictionary *)launchOptions]; // IOS6 and younger
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self finishLaunchingWithOptions:(NSDictionary *)launchOptions]; // IOS5 and older
    
    if (![CLLocationManager locationServicesEnabled]) {
        // no location services
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window.rootViewController.view animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
        hud.dimBackground = YES;
        hud.labelText = @"Location services not enabled";
        [hud show:YES];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
