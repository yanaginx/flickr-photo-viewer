//
//  LoadingButton.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 22/06/2022.
//

#import "LoadingButton.h"

@interface LoadingButton ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSString *originalButtonText;

@end

@implementation LoadingButton

- (instancetype)init {
    self = [super init];
    if (self) {
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = UIColor.whiteColor.CGColor;
        [self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [self setTitleColor:UIColor.blackColor forState:UIControlStateFocused];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
        self.titleLabel.highlightedTextColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    } else {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    }
}

- (void)showLoading {
    self.originalButtonText = self.titleLabel.text;
    [self setTitle:@""
          forState:UIControlStateNormal];
    [self showSpinning];
}

- (void)hideLoading {
    [self setTitle:self.originalButtonText
          forState:UIControlStateNormal];
    [self.activityIndicator stopAnimating];
    self.enabled = YES;
}

#pragma mark - Private methods
- (void)showSpinning {
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.activityIndicator];
    [self setActivityIndicatorInCenter];
    [self.activityIndicator startAnimating];
    self.enabled = NO;
}

- (void)setActivityIndicatorInCenter {
    NSLayoutConstraint *xCenterConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.activityIndicator
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1
                                                                          constant:0];
    [self addConstraint:xCenterConstraint];
    NSLayoutConstraint *yCenterConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.activityIndicator
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1
                                                                          constant:0];
    [self addConstraint:yCenterConstraint];
}

#pragma mark - Custom accessors
- (UIActivityIndicatorView *)activityIndicator {
    if (_activityIndicator) return _activityIndicator;
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    _activityIndicator.color = UIColor.whiteColor;
    _activityIndicator.hidesWhenStopped = YES;
    return _activityIndicator;
}


@end
