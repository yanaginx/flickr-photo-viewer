//
//  LoginViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.label];
    [self.label setAnchorCenterX:self.label.superview.centerXAnchor centerY:self.label.superview.centerYAnchor];
    
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

#pragma mark - Custom Accessors

- (UILabel *)label {
    if (_label) return _label;
    
    _label = [[UILabel alloc] init];
    return _label;
}

@end
