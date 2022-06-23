//
//  AppDelegate.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 15/06/2022.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (class, readonly, strong) AppDelegate *shared;

- (RootViewController *)rootViewController;

@end

