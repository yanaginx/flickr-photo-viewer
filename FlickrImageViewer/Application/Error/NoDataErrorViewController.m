//
//  NoDataErrorViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 29/06/2022.
//

#import "NoDataErrorViewController.h"
#import "ErrorViewConstants.h"

@interface NoDataErrorViewController ()

@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) UIImageView *noDataErrorImageView;
@property (nonatomic, strong) UILabel *noDataErrorCaption;

@end

@implementation NoDataErrorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    // Do any additional setup after loading the view.
    [self.view addSubview:self.retryButton];
    [self.view addSubview:self.noDataErrorCaption];
    [self.view addSubview:self.noDataErrorImageView];
    self.navigationItem.hidesBackButton = YES;
}

#pragma mark - Handler
- (void)onRetryButtonClicked {
    [self.delegate onRetryForNoDataErrorClicked];
}

#pragma mark - Custom Accessors

- (UILabel *)noDataErrorCaption {
    if (_noDataErrorCaption) return _noDataErrorCaption;
    
    _noDataErrorCaption = [[UILabel alloc] init];
    [_noDataErrorCaption setFont:[UIFont systemFontOfSize:18 weight:UIFontWeightBold]];
    _noDataErrorCaption.text = @"No photo yet!";
    _noDataErrorCaption.textAlignment = NSTextAlignmentCenter;
    _noDataErrorCaption.numberOfLines = 0;
    _noDataErrorCaption.frame = CGRectMake(kLabelX, kLabelY, kLabelWidth, kLabelHeight);
    return _noDataErrorCaption;
}

- (UIButton *)retryButton {
    if (_retryButton) return _retryButton;
    
    _retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
//    NSLog(@"[DEBUG] %s : buttonX: %f, buttonY: %f, width: %f, height: %f", __func__, kButtonX, kButtonY, kButtonWidth, kButtonHeight);
    _retryButton.frame = CGRectMake(kButtonX, kButtonY, kButtonWidth, kButtonHeight);
    _retryButton.layer.borderWidth = 1.0f;
    _retryButton.layer.cornerRadius = kButtonWidth / 8;
    _retryButton.layer.borderColor = UIColor.grayColor.CGColor;
    [_retryButton setTitle:@"TRY AGAIN" forState:UIControlStateNormal];
    [_retryButton addTarget:self
                     action:@selector(onRetryButtonClicked)
           forControlEvents:UIControlEventTouchUpInside];
    return _retryButton;
}

- (UIImageView *)noDataErrorImageView {
    if (_noDataErrorImageView) return _noDataErrorImageView;
    
    _noDataErrorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_no_data"]];
//    NSLog(@"[DEBUG] %s : labelX: %f, labelY: %f, width: %f, height: %f", __func__, kImageX, kImageY, kImageWidth, kImageHeight);
    _noDataErrorImageView.frame = CGRectMake(kImageX, kImageY, kImageWidth, kImageHeight);
    _noDataErrorImageView.contentMode = UIViewContentModeScaleAspectFill;
    return _noDataErrorImageView;
}

@end
