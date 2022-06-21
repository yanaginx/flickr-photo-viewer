//
//  LoginViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import "LoginViewController.h"

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
//    [NSNotificationCenter.defaultCenter addObserver:self
//                                           selector:@selector(showLoginWebView)
//                                               name:@"AuthorizationURLReady"
//                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserverForName:@"AuthorizationURLReady"
                                                    object:nil
                                                     queue:NSOperationQueue.mainQueue
                                                usingBlock:^(NSNotification * _Nonnull note) {
        [self showLoginWebView];
    }];
}

- (void)addCallbackObserver {
    // Subsribing the notification center for the message
//    [NSNotificationCenter.defaultCenter addObserver:self
//                                           selector:@selector(safariLogin:)
//                                               name:@"CallbackReceived"
//                                             object:nil];
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
        NSLog(@"[DEBUG] %s : error received: %@", __func__, error);
        NSLog(@"[DEBUG] %s : result data received: %@, %@", __func__, token, secret);
        if (token && secret) {
//            [NSUserDefaults.standardUserDefaults setObject:token forKey:@"request_oauth_token"];
//            [NSUserDefaults.standardUserDefaults setObject:secret forKey:@"request_oauth_token_secret"];
            NSLog(@"[DEBUG] %s : authorizationURL built: %@", __func__, LoginHandler.sharedLoginHandler.authorizationURL);
            [NSNotificationCenter.defaultCenter postNotificationName:@"AuthorizationURLReady"
                                                              object:self];
        }
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
    [self removeObservers];
    
    if ([notification.object isKindOfClass:[NSString class]]) {
        NSString *query = notification.object;
        NSLog(@"[DEBUG] %s : query result: %@", __func__, query);
        [LoginHandler.sharedLoginHandler parseTokenAndVerifierFromQuery:query];
    } else {
        NSLog(@"Went somewhere");
    }
    [self.safariViewController dismissViewControllerAnimated:YES completion:^{
        NSString *verifier = [NSUserDefaults.standardUserDefaults stringForKey:@"request_oauth_verifier"];
        self.label.text = verifier;
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
