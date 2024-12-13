//
//  AppDelegate.m
//  LNCollectionView
//
//  Created by Levison on 7.11.24.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    MainViewController *mainController = [[MainViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainController];
    nav.navigationBar.translucent = NO;
    _window.rootViewController = nav;
    [_window makeKeyAndVisible];
    
    return YES;
}

@end
