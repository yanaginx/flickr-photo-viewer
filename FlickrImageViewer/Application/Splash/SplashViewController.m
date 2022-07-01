//
//  SplashViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 22/06/2022.
//

#import "SplashViewController.h"
#import "../Main/AppDelegate.h"

@interface SplashViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.activityIndicator];
    
    self.activityIndicator.frame = self.view.bounds;
    self.activityIndicator.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    
    [self checkUserInfo];
}

#pragma mark - Private methods
-(void)checkUserInfo {
    [self.activityIndicator startAnimating];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC),
                   dispatch_get_main_queue(),
                   ^{
        [self.activityIndicator stopAnimating];
        if (didUserLoggedIn()) {
            /// Navigate to Home view
            [AppDelegate.shared.rootViewController switchToHomeScreen];
        } else {
            /// Navigate to Login view
            [AppDelegate.shared.rootViewController switchToLogOut];
        }
    });
}

#pragma mark - Custom accessors
- (UIActivityIndicatorView *)activityIndicator {
    if (_activityIndicator) return _activityIndicator;
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    return _activityIndicator;
}

#pragma mark - Helpers
BOOL didUserLoggedIn(void) {
    return ([NSUserDefaults.standardUserDefaults objectForKey:@"user_oauth_token"] != nil);
}

@end
