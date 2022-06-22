//
//  RootViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 22/06/2022.
//

#import "RootViewController.h"
#import "../Splash/SplashViewController.h"
#import "../Login/LoginViewController.h"
#import "../Home/HomeViewController.h"

@interface RootViewController ()

@property (nonatomic) UIViewController *currentVC;

@end

@implementation RootViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentVC = [[SplashViewController alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addChildViewController:self.currentVC];
    self.currentVC.view.frame = self.view.bounds;
    [self.view addSubview:self.currentVC.view];
    [self.currentVC didMoveToParentViewController:self];
}

#pragma mark - Navigation methods
- (void)showLoginScreen {
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    UINavigationController *newNavi = [[UINavigationController alloc] initWithRootViewController:loginVC];
    
    [self addChildViewController:newNavi];
    newNavi.view.frame = self.view.bounds;
    [self.view addSubview:newNavi.view];
    [newNavi didMoveToParentViewController:self];
    
    [self.currentVC willMoveToParentViewController:nil];
    [self.currentVC.view removeFromSuperview];
    [self.currentVC removeFromParentViewController];
    
    self.currentVC = newNavi;
}

- (void)switchToHomeScreen {
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    UINavigationController *homeNavi = [[UINavigationController alloc] initWithRootViewController:homeVC];
    
    
}

- (void)animateFadeTransitionToNewViewController:(UIViewController *)newVC completion:(void(^)(void))completion {
    [self.currentVC willMoveToParentViewController:nil];
    [self addChildViewController:newVC];
    
    [self transitionFromViewController:self.currentVC toViewController:newVC duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{} completion:^(BOOL finished) {
        [self.currentVC removeFromParentViewController];
        [newVC didMoveToParentViewController:self];
        self.currentVC = newVC;
        completion();
    }];
}

- (void)switchToLogOut {
    
}

@end
