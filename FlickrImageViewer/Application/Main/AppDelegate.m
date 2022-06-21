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


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [UIWindow new];
    [self.window makeKeyAndVisible];
    
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    
    self.window.rootViewController = loginVC;

    return YES;
}


#pragma mark - <UIApplicationDelegate>
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@"application: %@", app);
    NSLog(@"url: %@", !url.baseURL ? @"No base URL" : url.baseURL.absoluteString);
    NSLog(@"url query: %@", !url.query ? @"No query string" : url.query);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    // Sending the message to notification center whenever
    // the listener get the message from the sender
    if (url.query) {
        NSArray *queryItem = [url.query componentsSeparatedByString:@"&"];
        
        for (NSString *pair in queryItem) {
            NSArray *item = [pair componentsSeparatedByString:@"="];
            if (item.count == 2) {
                [params setValue:item[1] forKey:item[0]];
            }
        }
        
        NSString *message = [params objectForKey:@"oauth_token"];
        if (message) {
            NSNotificationName notiName = @"MessageReceived";
            [[NSNotificationCenter defaultCenter] postNotificationName:notiName object:message];
        }
    }
    
    return YES;
}

@end
