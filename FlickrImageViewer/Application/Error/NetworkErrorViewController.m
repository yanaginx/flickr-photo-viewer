//
//  NetworkErrorViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 29/06/2022.
//

#import "NetworkErrorViewController.h"
#import "ErrorViewConstants.h"

@interface NetworkErrorViewController ()

@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) UIImageView *networkErrorImageView;
@property (nonatomic, strong) UILabel *networkErrorCaption;

@end

@implementation NetworkErrorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    // Do any additional setup after loading the view.
    [self.view addSubview:self.retryButton];
    [self.view addSubview:self.networkErrorCaption];
    [self.view addSubview:self.networkErrorImageView];
}

#pragma mark - Handler
- (void)onRetryButtonClicked {
    [self.delegate onRetryForNetworkErrorClicked];
}

#pragma mark - Custom Accessors

- (UILabel *)networkErrorCaption {
    if (_networkErrorCaption) return _networkErrorCaption;
    
    _networkErrorCaption = [[UILabel alloc] init];
    _networkErrorCaption.text = @"Network problem occured!\nPlease try again";
    _networkErrorCaption.textAlignment = NSTextAlignmentCenter;
    _networkErrorCaption.numberOfLines = 0;
//    NSLog(@"[DEBUG] %s : labelX: %f, labelY: %f, width: %f, height: %f", __func__, kLabelX, kLabelY, kLabelWidth, kLabelHeight);
    _networkErrorCaption.frame = CGRectMake(kLabelX, kLabelY, kLabelWidth, kLabelHeight);
//    _networkErrorCaption.frame = CGRectMake(self.view.center.x - (self.view.frame.size.width - 50 * 2) / 2,
//                                    self.view.center.y + (self.view.frame.size.height / 10),
//                                    self.view.frame.size.width - 50 * 2,
//                                    200);
    return _networkErrorCaption;
}

- (UIButton *)retryButton {
    if (_retryButton) return _retryButton;
    
    _retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    NSLog(@"[DEBUG] %s : buttonX: %f, buttonY: %f, width: %f, height: %f", __func__, kButtonX, kButtonY, kButtonWidth, kButtonHeight);
    _retryButton.frame = CGRectMake(kButtonX, kButtonY, kButtonWidth, kButtonHeight);
    [_retryButton setTitle:@"TRY AGAIN" forState:UIControlStateNormal];
    [_retryButton addTarget:self
                     action:@selector(onRetryButtonClicked)
           forControlEvents:UIControlEventTouchUpInside];
    return _retryButton;
}

- (UIImageView *)networkErrorImageView {
    if (_networkErrorImageView) return _networkErrorImageView;
    
    _networkErrorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_no_network"]];
    NSLog(@"[DEBUG] %s : labelX: %f, labelY: %f, width: %f, height: %f", __func__, kImageX, kImageY, kImageWidth, kImageHeight);
    _networkErrorImageView.frame = CGRectMake(kImageX, kImageY, kImageWidth, kImageHeight);
    _networkErrorImageView.contentMode = UIViewContentModeScaleAspectFill;
    return _networkErrorImageView;
}

@end
