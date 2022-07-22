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
#import "../../Common/Constants/Constants.h"

#import "../../Common/ViewComponents/Buttons/LoadingButton.h"


@interface LoginViewController () <LoginHandlerDelegate,
                                   ASWebAuthenticationPresentationContextProviding>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) LoadingButton *beginButton;
@property (nonatomic, strong) ASWebAuthenticationSession *authSession;
@property (nonatomic, strong) LoginHandler *loginHandler;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.cyanColor;
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    backgroundImage.image = [UIImage imageNamed:@"onboarding_background"];
    [self.view insertSubview:backgroundImage atIndex:0];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.captionLabel];
    [self.view addSubview:self.beginButton];
    
    [self.beginButton setTitle:NSLocalizedString(@"Get started button text", nil) forState:UIControlStateNormal];
    [self.beginButton addTarget:self action:@selector(_onClickGetStarted) forControlEvents:UIControlEventTouchUpInside];
    
    self.loginHandler.delegate = self;
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)dealloc {
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
    NSLog(@"Login view controller did dealloc");
}

#pragma mark - Private methods

- (void)_onClickGetStarted {
    [self.beginButton showLoading];
    [self.loginHandler startAuthenticationProcess];
}


#pragma mark - ASWebAuthenticationPresentationContextProviding
- (ASPresentationAnchor)presentationAnchorForWebAuthenticationSession:(ASWebAuthenticationSession *)session {
    return self.view.window;
}

#pragma mark - LoginHandlerDelegate
- (void)onFinishGettingRequestTokenWithErrorCode:(LoginHandlerErrorCode)errorCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (errorCode) {
            case LoginHandlerErrorNotValidData:
                // Toast not valid data
                NSLog(@"[ERROR] %s: NOT VALID DATA", __func__);
                [self.beginButton hideLoading];
                break;
            case LoginHandlerErrorServerError:
                // Toast server error
                NSLog(@"[ERROR] %s: SERVER ERROR", __func__);
                [self.beginButton hideLoading];
                break;
            case LoginHandlerErrorNetworkError:
                // Toast network error
                NSLog(@"[ERROR] %s: NETWORK ERROR", __func__);
                [self.beginButton hideLoading];
                break;
            case LoginHandlerErrorInvalidURL:
                // Toast invalid URL error
                NSLog(@"[ERROR] %s: INVALID URL ERROR", __func__);
                [self.beginButton hideLoading];
                break;
            default:
                NSLog(@"[INFO] %s: GOT THE TOKEN", __func__);
                break;
        }
    });
}

- (void)requestAuthorizationUsingAuthSession:(ASWebAuthenticationSession *)authSession {
    self.authSession = authSession;
    self.authSession.presentationContextProvider = self;
    self.authSession.prefersEphemeralWebBrowserSession = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.authSession start];
    });
}

- (void)onFinishGettingAuthorizationWithErrorCode:(LoginHandlerErrorCode)errorCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (errorCode) {
            case LoginHandlerErrorNotValidData:
                // Toast not valid data
                NSLog(@"[ERROR] %s: NOT VALID DATA", __func__);
                [self.beginButton hideLoading];
                break;
            case LoginHandlerErrorServerError:
                // Toast server error
                NSLog(@"[ERROR] %s: SERVER ERROR", __func__);
                [self.beginButton hideLoading];
                break;
            case LoginHandlerErrorNetworkError:
                // Toast network error
                NSLog(@"[ERROR] %s: NETWORK ERROR", __func__);
                [self.beginButton hideLoading];
                break;
            case LoginHandlerErrorInvalidURL:
                // Toast invalid URL error
                NSLog(@"[ERROR] %s: INVALID URL ERROR", __func__);
                [self.beginButton hideLoading];
                break;
            default:
                NSLog(@"[INFO] %s: GOT THE TOKEN", __func__);
                break;
        }
    });
}

- (void)onFinishGettingAccessTokenWithErrorCode:(LoginHandlerErrorCode)errorCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (errorCode) {
            case LoginHandlerErrorNotValidData:
                // Toast not valid data
                NSLog(@"[ERROR] %s: NOT VALID DATA", __func__);
                [self.beginButton hideLoading];
                break;
            case LoginHandlerErrorServerError:
                // Toast server error
                NSLog(@"[ERROR] %s: SERVER ERROR", __func__);
                [self.beginButton hideLoading];
                break;
            case LoginHandlerErrorNetworkError:
                // Toast network error
                NSLog(@"[ERROR] %s: NETWORK ERROR", __func__);
                [self.beginButton hideLoading];
                break;
            case LoginHandlerErrorInvalidURL:
                // Toast invalid URL error
                NSLog(@"[ERROR] %s: INVALID URL ERROR", __func__);
                [self.beginButton hideLoading];
                break;
            default:
                NSLog(@"[INFO] %s: GOT THE TOKEN", __func__);
                break;
        }
    });
}

- (void)onFinishSavingUserInfo:(LoginHandlerErrorCode)errorCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (errorCode) {
            case LoginHandlerErrorNotValidData:
                // Toast not valid data
                NSLog(@"[ERROR] %s: NOT VALID DATA", __func__);
                [self.beginButton hideLoading];
                break;
            default:
                // Switch to home view
                NSLog(@"[INFO] %s: SWITCH TO HOMEVIEW", __func__);
                [AppDelegate.shared updateView];
                break;
        }
    });
}


#pragma mark - Custom Accessors
- (LoginHandler *)loginHandler {
    if (_loginHandler) return _loginHandler;
    
    _loginHandler = [[LoginHandler alloc] init];
    return _loginHandler;
}

- (UILabel *)titleLabel {
    if (_titleLabel) return _titleLabel;
    
    _titleLabel = [[UILabel alloc] init];
    [_titleLabel setFont:[UIFont systemFontOfSize:32 weight:UIFontWeightBold]];
    _titleLabel.text = @"FLICKRz";
    _titleLabel.textColor = UIColor.whiteColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.frame = CGRectMake(self.view.center.x - kFrameWidth/2 ,
                                   self.view.center.y - (self.view.frame.size.height/4),
                                   kFrameWidth,
                                   kFrameHeight);
    return _titleLabel;
}

- (UILabel *)captionLabel {
    if (_captionLabel) return _captionLabel;
    
    _captionLabel = [[UILabel alloc] init];
    _captionLabel.text = @"From photos to moments";
    _captionLabel.textColor = UIColor.whiteColor;
    _captionLabel.textAlignment = NSTextAlignmentCenter;
    _captionLabel.frame = CGRectMake(self.view.center.x - (self.view.frame.size.width - kButtonMargin * 2) / 2,
                                    self.view.center.y + (self.view.frame.size.height / 10),
                                    self.view.frame.size.width - kButtonMargin * 2,
                                    kFrameHeight);
    return _captionLabel;
}

- (LoadingButton *)beginButton {
    if (_beginButton) return _beginButton;
    
    _beginButton = [[LoadingButton alloc] init];
        
    _beginButton.frame = CGRectMake(self.view.center.x - (self.view.frame.size.width - kButtonMargin * 2) / 2,
                                    self.view.center.y + (self.view.frame.size.height / 4),
                                    self.view.frame.size.width - kButtonMargin * 2,
                                    kFrameHeight);
    return _beginButton;
}

@end
