//
//  PermissionErrorViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 07/07/2022.
//

#import "PermissionErrorViewController.h"
#import "ErrorViewConstants.h"

@interface PermissionErrorViewController ()

@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) UIImageView *permissionErrorImageView;
@property (nonatomic, strong) UILabel *permissionErrorCaption;

@end

@implementation PermissionErrorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    // Do any additional setup after loading the view.

    [self.view addSubview:self.retryButton];
    [self.view addSubview:self.permissionErrorCaption];
    [self.view addSubview:self.permissionErrorImageView];
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillLayoutSubviews {
    self.permissionErrorCaption.frame = CGRectMake(kLabelX, kLabelY, kLabelWidth, kLabelHeight);
    self.retryButton.frame = CGRectMake(kButtonX, kButtonY, kButtonWidth, kButtonHeight);
    self.permissionErrorImageView.frame = CGRectMake(kImageX, kImageY, kImageWidth, kImageHeight);
}

#pragma mark - Handler
- (void)onRetryButtonClicked {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate onRetryForPermissionErrorClicked];
    }];
}

#pragma mark - Private methods
- (void)_setupDismissButton {
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_cancel"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(_dismiss)];
    [self.navigationItem setLeftBarButtonItem:dismissButton];
}

- (void)_dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Custom Accessors

- (UILabel *)permissionErrorCaption {
    if (_permissionErrorCaption) return _permissionErrorCaption;
    
    _permissionErrorCaption = [[UILabel alloc] init];
    [_permissionErrorCaption setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightBold]];
    _permissionErrorCaption.text = @"We will need your photo permission\nto be able to upload photos";
    _permissionErrorCaption.textAlignment = NSTextAlignmentCenter;
    _permissionErrorCaption.numberOfLines = 0;
    return _permissionErrorCaption;
}

- (UIButton *)retryButton {
    if (_retryButton) return _retryButton;
    
//    UIButtonConfiguration *buttonConfiguration = [UIButtonConfiguration tintedButtonConfiguration];
//    buttonConfiguration.title = @"GRANT ACCESS";
//    UIAction *retryAction = [UIAction actionWithHandler:^(__kindof UIAction * _Nonnull action) {
//        [self onRetryButtonClicked];
//    }];
//    _retryButton = [UIButton buttonWithConfiguration:buttonConfiguration
//                                       primaryAction:retryAction];
    
    _retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _retryButton.layer.borderWidth = 1.0f;
    _retryButton.layer.cornerRadius = kCornerRadius;
    _retryButton.layer.borderColor = UIColor.grayColor.CGColor;
    [_retryButton setTitle:@"GRANT ACCESS" forState:UIControlStateNormal];
    [_retryButton addTarget:self
                     action:@selector(onRetryButtonClicked)
           forControlEvents:UIControlEventTouchUpInside];
    return _retryButton;
}

- (UIImageView *)permissionErrorImageView {
    if (_permissionErrorImageView) return _permissionErrorImageView;
    
    _permissionErrorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_gallery"]];
    _permissionErrorImageView.contentMode = UIViewContentModeScaleAspectFill;
    return _permissionErrorImageView;
}

@end
