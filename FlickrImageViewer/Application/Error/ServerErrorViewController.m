//
//  SomeErrorViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 29/06/2022.
//

#import "ServerErrorViewController.h"
#import "ErrorViewConstants.h"

@interface ServerErrorViewController ()

@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) UIImageView *serverErrorImageView;
@property (nonatomic, strong) UILabel *serverErrorCaption;

@end

@implementation ServerErrorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    // Do any additional setup after loading the view.
    [self.view addSubview:self.retryButton];
    [self.view addSubview:self.serverErrorCaption];
    [self.view addSubview:self.serverErrorImageView];
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillLayoutSubviews {
    self.serverErrorCaption.frame = CGRectMake(kLabelX, kLabelY, kLabelWidth, kLabelHeight);
    self.retryButton.frame = CGRectMake(kButtonX, kButtonY, kButtonWidth, kButtonHeight);
    self.serverErrorImageView.frame = CGRectMake(kImageX, kImageY, kImageWidth, kImageHeight);
}


#pragma mark - Handler
- (void)onRetryButtonClicked {
    [self.delegate onRetryForServerErrorClicked];
}

#pragma mark - Custom Accessors

- (UILabel *)serverErrorCaption {
    if (_serverErrorCaption) return _serverErrorCaption;
    
    _serverErrorCaption = [[UILabel alloc] init];
    [_serverErrorCaption setFont:[UIFont systemFontOfSize:18 weight:UIFontWeightBold]];
    _serverErrorCaption.text = NSLocalizedString(@"Server error label", nil);
    _serverErrorCaption.textAlignment = NSTextAlignmentCenter;
    _serverErrorCaption.numberOfLines = 0;
    return _serverErrorCaption;
}

- (UIButton *)retryButton {
    if (_retryButton) return _retryButton;
    
    _retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
//    NSLog(@"[DEBUG] %s : buttonX: %f, buttonY: %f, width: %f, height: %f", __func__, kButtonX, kButtonY, kButtonWidth, kButtonHeight);
    _retryButton.layer.borderWidth = 1.0f;
    _retryButton.layer.cornerRadius = kCornerRadius;
    _retryButton.layer.borderColor = UIColor.grayColor.CGColor;
    [_retryButton setTitle:NSLocalizedString(@"Try again button text", nil) forState:UIControlStateNormal];
    [_retryButton addTarget:self
                     action:@selector(onRetryButtonClicked)
           forControlEvents:UIControlEventTouchUpInside];
    return _retryButton;
}

- (UIImageView *)serverErrorImageView {
    if (_serverErrorImageView) return _serverErrorImageView;
    
    _serverErrorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_server_error"]];
//    NSLog(@"[DEBUG] %s : labelX: %f, labelY: %f, width: %f, height: %f", __func__, kImageX, kImageY, kImageWidth, kImageHeight);
    _serverErrorImageView.contentMode = UIViewContentModeScaleAspectFill;
    return _serverErrorImageView;
}

@end
