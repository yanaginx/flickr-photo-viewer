//
//  AppDelegate.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 15/06/2022.
//

#import "AppDelegate.h"
#import "../Login/LoginViewController.h"
#import "../Home/HomeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (AppDelegate *)shared {
    return (AppDelegate *)UIApplication.sharedApplication.delegate;
}

- (RootViewController *)rootViewController {
    return (RootViewController *)self.window.rootViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] init];
    RootViewController *rootVC = [[RootViewController alloc] init];
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
//    NSLog(@"%s : is Logged in? %d", __func__, isLoggedIn());
    return YES;
}

- (void)switchToHomeView {
    NSLog(@"%s", __func__);
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    self.window.rootViewController = homeVC;
    [self.window makeKeyAndVisible];
}

- (void)switchToLoginView {
    NSLog(@"%s", __func__);
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    self.window.rootViewController = loginVC;
    [self.window makeKeyAndVisible];

}


#pragma mark - <UIApplicationDelegate>
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@"application: %@", app);
    NSLog(@"url: %@", !url.baseURL ? @"No base URL" : url.baseURL.absoluteString);
    NSLog(@"url query: %@", !url.query ? @"No query string" : url.query);
    
    // Sending the message to notification center whenever
    // the listener get the message from the sender
    if (url.query) {
        NSString *message = url.query;
        if (message) {
            NSNotificationName notiName = @"CallbackReceived";
            [[NSNotificationCenter defaultCenter] postNotificationName:notiName object:message];
        }
    }
    
    return YES;
}

//#pragma mark - Helpers
//BOOL isLoggedIn(void) {
//    return ([NSUserDefaults.standardUserDefaults objectForKey:@"user_oauth_token"] != nil);
//}



@end
