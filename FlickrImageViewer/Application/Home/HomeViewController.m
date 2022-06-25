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
    UIImage *popularIconOutlined = [[UIImage imageNamed:@"ic_dashboard_outlined"]
                                    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    popularVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Dashboard"
                                                         image:popularIconOutlined
                                                 selectedImage:popularIcon];
    
    UIViewController *uploadVC = [[UploadViewController alloc] init];
    UINavigationController *uploadNavi = [[UINavigationController alloc] initWithRootViewController:uploadVC];
    UIImage *uploadIcon = [[UIImage imageNamed:@"ic_publish"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *uploadIconOutlined = [[UIImage imageNamed:@"ic_publish_outlined"]
                                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    uploadVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Upload"
                                                        image:uploadIconOutlined
                                                selectedImage:uploadIcon];
    
    UIViewController *userVC = [[UserProfileViewController alloc] init];
    UINavigationController *userNavi = [[UINavigationController alloc] initWithRootViewController:userVC];
    UIImage *profileIcon = [[UIImage imageNamed:@"ic_person"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *profileIconOutlined = [[UIImage imageNamed:@"ic_person_outlined"]
                                    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    userVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Profile"
                                                      image:profileIconOutlined
                                              selectedImage:profileIcon];

    self.viewControllers = [NSArray arrayWithObjects:
                            popularNavi,
                            uploadNavi,
                            userNavi,
                            nil];
}

@end
