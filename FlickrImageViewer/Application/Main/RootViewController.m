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

- (instancetype)init {
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
    UINavigationController *loginNavi = [[UINavigationController alloc] initWithRootViewController:loginVC];
    
    [self addChildViewController:loginNavi];
    loginNavi.view.frame = self.view.bounds;
    [self.view addSubview:loginNavi.view];
    [loginNavi didMoveToParentViewController:self];
    
    [self.currentVC willMoveToParentViewController:nil];
    [self.currentVC.view removeFromSuperview];
    [self.currentVC removeFromParentViewController];
    
    self.currentVC = loginNavi;
}

- (void)switchToHomeScreen {
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    UINavigationController *homeNavi = [[UINavigationController alloc] initWithRootViewController:homeVC];
    [self animateFadeTransitionToNewViewController:homeNavi completion:nil];
}

- (void)switchToLogOut {
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    UINavigationController *loginNavi = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self animateDismissTransitionToNewViewController:loginNavi completion:nil];
}

- (void)animateFadeTransitionToNewViewController:(UIViewController *)newVC completion:(void(^ __nullable)(void))completion {
    [self.currentVC willMoveToParentViewController:nil];
    [self addChildViewController:newVC];
    
    [self transitionFromViewController:self.currentVC toViewController:newVC duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{} completion:^(BOOL finished) {
        [self.currentVC removeFromParentViewController];
        [newVC didMoveToParentViewController:self];
        self.currentVC = newVC;
        if (completion) completion();
    }];
}

- (void)animateDismissTransitionToNewViewController:(UIViewController *)newVC completion:(void(^ __nullable)(void))completion {
    CGRect initialFrame = CGRectMake(-self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.currentVC willMoveToParentViewController:nil];
    [self addChildViewController:newVC];
    newVC.view.frame = initialFrame;
    
    [self transitionFromViewController:self.currentVC toViewController:newVC duration:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
        newVC.view.frame = self.view.bounds;
    } completion:^(BOOL finished) {
        [self.currentVC removeFromParentViewController];
        [newVC didMoveToParentViewController:self];
        self.currentVC = newVC;
        if (completion) completion();
    }];
}





@end
