//
//  HomeViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIViewController *popularVC = [[PopularViewController alloc] init];
    UINavigationController *popularNavi = [[UINavigationController alloc] initWithRootViewController:popularVC];
    UIImage *popularIcon = [[UIImage imageNamed:@"ic_dashboard"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    popularVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Dashboard"
                                                         image:popularIcon
                                                           tag:0];
    
    UIViewController *uploadVC = [[UploadViewController alloc] init];
    UINavigationController *uploadNavi = [[UINavigationController alloc] initWithRootViewController:uploadVC];
    UIImage *uploadIcon = [[UIImage imageNamed:@"ic_publish"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    uploadVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Upload"
                                                        image:uploadIcon
                                                          tag:1];
    
    UIViewController *profileVC = [[ProfileViewController alloc] init];
    UINavigationController *profileNavi = [[UINavigationController alloc] initWithRootViewController:profileVC];
    UIImage *profileIcon = [[UIImage imageNamed:@"ic_person"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    profileVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Profile"
                                                         image:profileIcon
                                                           tag:2];

    self.viewControllers = [NSArray arrayWithObjects:
                            popularNavi,
                            uploadNavi,
                            profileNavi,
                            nil];
}

@end
