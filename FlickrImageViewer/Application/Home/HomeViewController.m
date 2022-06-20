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
    popularVC.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites
                                                                      tag:0];
    
    UIViewController *uploadVC = [[UploadViewController alloc] init];
    UINavigationController *uploadNavi = [[UINavigationController alloc] initWithRootViewController:uploadVC];
    uploadVC.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore
                                                                     tag:1];
    
    UIViewController *profileVC = [[ProfileViewController alloc] init];
    UINavigationController *profileNavi = [[UINavigationController alloc] initWithRootViewController:profileVC];
    profileNavi.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts
                                                                        tag:2];

    

    self.viewControllers = [NSArray arrayWithObjects:
                            popularNavi,
                            uploadNavi,
                            profileNavi,
                            nil];
}

@end
