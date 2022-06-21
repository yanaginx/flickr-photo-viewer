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


@interface LoginViewController ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *getStartedButton;

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
    
    // http%3A%2F%2Fwww.example.com
    self.label.text = [@"http://www.example.com" URLEncodedString];
    
    [self addObserver];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeObserver];
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

- (void)addObserver {
    // Subsribing the notification center for the message
    [[NSNotificationCenter defaultCenter] addObserverForName:@"MessageReceived" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        if ([[notification object] isKindOfClass:[NSString class]]) {
            NSString *message = [notification object];
            self.label.text = [message stringByRemovingPercentEncoding];
        }
    }];
}

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MessageReceived" object:nil];
}

- (void)getRequestToken {
    [[LoginHandler sharedLoginHandler] getRequestTokenWithCompletionHandler:^(NSString * _Nullable token,
                                                                              NSString * _Nullable secret,
                                                                              NSError * _Nullable error) {
        NSLog(@"[DEBUG] %s : error received: %@", __func__, error);
        NSLog(@"[DEBUG] %s : result data received: %@, %@", __func__, token, secret);
        if (token && secret) {
            [NSUserDefaults.standardUserDefaults setObject:token forKey:@"request_oauth_token"];
            [NSUserDefaults.standardUserDefaults setObject:secret forKey:@"request_oauth_token_secret"];
        }
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
