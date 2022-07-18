//
//  AppDelegate.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 15/06/2022.
//

#import "AppDelegate.h"
#import "../../Common/Utilities/AccountManager/AccountManager.h"

#import "../Login/LoginViewController.h"
#import "../Home/HomeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (AppDelegate *)shared {
    return (AppDelegate *)UIApplication.sharedApplication.delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] init];
    [self updateView];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)updateView {
    if (AccountManager.isUserLoggedIn) {
        [self switchToHomeView];
    } else {
        [self switchToLoginView];
    }
}

#pragma mark - Operations
- (void)switchToLoginView {
    if (self.window.rootViewController != nil) {
        [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    }
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    self.window.rootViewController = loginViewController;
}

- (void)switchToHomeView {
    if (self.window.rootViewController != nil) {
        [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    }
    HomeViewController *homeViewController = [[HomeViewController alloc] init];
    self.window.rootViewController = homeViewController;
}

@end
