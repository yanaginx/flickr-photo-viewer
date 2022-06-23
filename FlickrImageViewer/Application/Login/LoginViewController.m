//
//  LoginViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import "LoginViewController.h"
#import "../Home/HomeViewController.h"
#import "../Main/AppDelegate.h"

#import "Handlers/LoginHandler.h"
#import "../../Common/Extensions/UIView+Additions.h"
#import "../../Common/Extensions/NSString+Additions.h"

#import "../../Common/ViewComponents/Buttons/LoadingButton.h"


@interface LoginViewController () <ASWebAuthenticationPresentationContextProviding>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) LoadingButton *beginButton;
@property (nonatomic, strong) ASWebAuthenticationSession *authSession;

@end

@implementation LoginViewController

static CGFloat buttonMargin = 50;
static CGFloat frameHeight = 60;
static CGFloat frameWidth = 200;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.cyanColor;
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    backgroundImage.image = [UIImage imageNamed:@"onboarding_background"];
    [self.view insertSubview:backgroundImage atIndex:0];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.captionLabel];
    [self.view addSubview:self.beginButton];
    
    [self.beginButton setTitle:@"GET STARTED" forState:UIControlStateNormal];
    [self.beginButton addTarget:self action:@selector(onClickGetStarted) forControlEvents:UIControlEventTouchUpInside];
    
    [self addAuthorizationObserver];
    [self addAccessTokenRequestObserver];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)dealloc {
    NSLog(@"Login view controller did dealloc");
}

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

- (void)removeObservers {
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"CallbackReceived" object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"AuthorizationURLReady" object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"AuthorizationSuccessful" object:nil];
}

- (void)onClickGetStarted {
    [self.beginButton showLoading];
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
            // disable the loading on button
            [self.beginButton hideLoading];
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
                [self.beginButton hideLoading];
                /// Navigate to Home screen
                [AppDelegate.shared.rootViewController switchToHomeScreen];
                /*
                // this is only for checking token's validity, the screen flow will be edited later
                AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
                [appDelegate switchToHomeView];
                */
            });
        }
        
        if (error) {
            [self.beginButton hideLoading];
            NSLog(@"[DEBUG] %s : error received: %@", __func__, error);
            return;
        }
        
        [self removeObservers];
    }];
}



#pragma mark - Notification selectors

- (void)showLoginWebView {
    self.authSession = [LoginHandler.sharedLoginHandler authSessionWithCompletionHandler:^(NSString * _Nullable token,
                                                                                           NSString * _Nullable verifier,
                                                                                           NSError * _Nullable error) {
        if (error) {
            // error handling
            NSLog(@"[DEBUG] %s: error: %@", __func__, error);
            [self.beginButton hideLoading];
        }
        NSLog(@"[DEBUG] %s: verifier: %@", __func__, verifier);
        NSLog(@"[DEBUG] %s: token: %@", __func__, token);
        if (!token || !verifier) return;
        [NSNotificationCenter.defaultCenter postNotificationName:@"AuthorizationSuccessful"
                                                          object:nil];
    }];;
    self.authSession.presentationContextProvider = self;
    [self.authSession start];
}

#pragma mark - ASWebAuthenticationPresentationContextProviding
- (ASPresentationAnchor)presentationAnchorForWebAuthenticationSession:(ASWebAuthenticationSession *)session {
    return self.view.window;
}


#pragma mark - Custom Accessors

- (UILabel *)titleLabel {
    if (_titleLabel) return _titleLabel;
    
    _titleLabel = [[UILabel alloc] init];
    [_titleLabel setFont:[UIFont systemFontOfSize:32 weight:UIFontWeightBold]];
    _titleLabel.text = @"FLICKRz";
    _titleLabel.textColor = UIColor.whiteColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.frame = CGRectMake(self.view.center.x - frameWidth/2 ,
                                   self.view.center.y - (self.view.frame.size.height/4),
                                   frameWidth,
                                   frameHeight);
    return _titleLabel;
}

- (UILabel *)captionLabel {
    if (_captionLabel) return _captionLabel;
    
    _captionLabel = [[UILabel alloc] init];
    _captionLabel.text = @"From photos to moments";
    _captionLabel.textColor = UIColor.whiteColor;
    _captionLabel.textAlignment = NSTextAlignmentCenter;
    _captionLabel.frame = CGRectMake(self.view.center.x - (self.view.frame.size.width - buttonMargin * 2) / 2,
                                    self.view.center.y + (self.view.frame.size.height / 10),
                                    self.view.frame.size.width - buttonMargin * 2,
                                    frameHeight);
    return _captionLabel;
}

- (LoadingButton *)beginButton {
    if (_beginButton) return _beginButton;
    
    _beginButton = [[LoadingButton alloc] init];
        
    _beginButton.frame = CGRectMake(self.view.center.x - (self.view.frame.size.width - buttonMargin * 2) / 2,
                                    self.view.center.y + (self.view.frame.size.height / 4),
                                    self.view.frame.size.width - buttonMargin * 2,
                                    frameHeight);
    return _beginButton;
}

@end
