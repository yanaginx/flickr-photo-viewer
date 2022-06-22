//
//  LoginViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import "LoginViewController.h"
#import "../Home/HomeViewController.h"

#import "Handlers/LoginHandler.h"
#import "../../Common/Extensions/UIView+Additions.h"
#import "../../Common/Extensions/NSString+Additions.h"



@interface LoginViewController () <SFSafariViewControllerDelegate>

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *getStartedButton;
@property (nonatomic, strong) SFSafariViewController *safariViewController;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.cyanColor;
    [self.view addSubview:self.label];
    [self.view addSubview:self.getStartedButton];
    
    [self.getStartedButton setTitle:@"GET STARTED" forState:UIControlStateNormal];
    [self.getStartedButton addTarget:self action:@selector(getRequestToken) forControlEvents:UIControlEventTouchUpInside];
    [self.label setAnchorCenterX:self.label.superview.centerXAnchor centerY:self.label.superview.centerYAnchor];
    
    self.label.text = @"FLICKRz";
    [self.label setFont:[UIFont systemFontOfSize:32]];
    
    [self addAuthorizationObserver];
    [self addAccessTokenRequestObserver];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private methods

- (void)addAuthorizationObserver {
    [NSNotificationCenter.defaultCenter addObserverForName:@"AuthorizationURLReady"
                                                    object:nil
                                                     queue:NSOperationQueue.mainQueue
                                                usingBlock:^(NSNotification *notification) {
        [self showLoginWebView];
    }];
}

- (void)addAccessTokenRequestObserver {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(getAccessToken)
                                               name:@"AuthorizationSuccessful"
                                             object:nil];
}

- (void)addCallbackObserver {
    [NSNotificationCenter.defaultCenter addObserverForName:@"CallbackReceived"
                                                    object:nil
                                                     queue:[NSOperationQueue mainQueue]
                                                usingBlock:^(NSNotification *notification) {
        [self safariLogin:notification];
    }];
}


- (void)removeObservers {
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"CallbackReceived" object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"AuthorizationURLReady" object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"AuthorizationSuccessful" object:nil];
}

- (void)onClickGetStarted {
    if (LoginHandler.sharedLoginHandler.authorizationURL) {
        NSLog(@"[DEBUG] %s : authorizationURL received: %@", __func__, LoginHandler.sharedLoginHandler.authorizationURL);
        [NSNotificationCenter.defaultCenter postNotificationName:@"AuthorizationURLReady"
                                                          object:self];
    } else {
        [self getRequestToken];
    }

}

- (void)getRequestToken {
    [LoginHandler.sharedLoginHandler getRequestTokenWithCompletionHandler:^(NSString * _Nullable token,
                                                                            NSString * _Nullable secret,
                                                                            NSError * _Nullable error) {
        if (![token isEqualToString:@""] &&
            ![secret isEqualToString:@""]) {
            NSLog(@"[DEBUG] %s : authorizationURL built: %@", __func__, LoginHandler.sharedLoginHandler.authorizationURL);
            [NSNotificationCenter.defaultCenter postNotificationName:@"AuthorizationURLReady"
                                                              object:self];
        }
        // error handling
        if (error) {
            NSLog(@"[DEBUG] %s : error received: %@", __func__, error);
        }
    }];
}

- (void)getAccessToken {
    [LoginHandler.sharedLoginHandler getAccessTokenWithCompletionHandler:^(NSString * _Nullable token,
                                                                           NSString * _Nullable tokenSecret,
                                                                           NSError * _Nullable error) {
        if (![token isEqualToString:@""] &&
            ![tokenSecret isEqualToString:@""]) {
            NSLog(@"[DEBUG] %s : user token: %@", __func__, LoginHandler.sharedLoginHandler.userAccessToken);
            NSLog(@"[DEBUG] %s : user tokenSecret: %@", __func__, LoginHandler.sharedLoginHandler.userTokenSecret);
            dispatch_async(dispatch_get_main_queue(), ^{
                // redirect user to the tabbar controller
                // this is only for checking token's validity, the screen flow will be edited later
                HomeViewController *homeVC = [[HomeViewController alloc] init];
                [self presentViewController:homeVC animated:YES completion:nil];
            });
        }
        
        if (error) {
            NSLog(@"[DEBUG] %s : error received: %@", __func__, error);
        }
        
        [self removeObservers];
    }];
}

#pragma mark - Notification selectors

- (void)showLoginWebView {
    [self addCallbackObserver];
    self.safariViewController = [[SFSafariViewController alloc] initWithURL:LoginHandler.sharedLoginHandler.authorizationURL];
    self.safariViewController.delegate = self;
    [self presentViewController:self.safariViewController animated:YES completion:nil];
    NSLog(@"BOOM!");
}

- (void)safariLogin:(NSNotification *)notification {
//    [self removeObservers];
    
    if ([notification.object isKindOfClass:[NSString class]]) {
        NSString *query = notification.object;
        [LoginHandler.sharedLoginHandler parseTokenAndVerifierFromQuery:query];
    }
    [self.safariViewController dismissViewControllerAnimated:YES completion:^{
        // Check if the verifier retrieved
        if ([NSUserDefaults.standardUserDefaults objectForKey:@"request_oauth_verifier"] == nil) {
            // display error using toast, then let the user retry
            NSLog(@"No verifier to be found!");
            self.label.text = @"No verifier to be found! Please try again";
            return;
        }
        // if no error then proceed the getting access token
        [NSNotificationCenter.defaultCenter postNotificationName:@"AuthorizationSuccessful"
                                                          object:nil];
    }];
}

#pragma mark - Custom Accessors

- (UILabel *)label {
    if (_label) return _label;
    
    _label = [[UILabel alloc] init];
    return _label;
}

- (UIButton *)getStartedButton {
    if (_getStartedButton) return _getStartedButton;
    
    _getStartedButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _getStartedButton.frame = CGRectMake(self.view.center.x - 100, self.view.center.y + (self.view.frame.size.height / 4), 200, 60);
    return _getStartedButton;
}

@end
