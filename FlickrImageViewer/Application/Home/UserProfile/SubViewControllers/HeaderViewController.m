//
//  HeaderViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 30/06/2022.
//

#import "HeaderViewController.h"
#import "../UserProfileConstants.h"

@interface HeaderViewController ()

@end

@implementation HeaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:blurEffectView atIndex:0];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ic_person_outlined"]];
}

- (void)viewWillLayoutSubviews {
    [self.view addSubview:self.avatarImageView];
    [self setAvatarImageViewAnchor];
    [self.view addSubview:self.nameLabel];
    [self setNameLabelAnchor];
    [self.view addSubview:self.numberOfPhotosLabel];
    [self setNumberOfPhotosLabelAnchor];
    NSLog(@"[DEBUG] %s: %f", __func__, self.view.frame.size.height);
    NSLog(@"[DEBUG] %s: %f", __func__, self.view.frame.size.width);
}

#pragma mark - Helpers
- (void)setAvatarImageViewAnchor {
    [[self.avatarImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                    constant:kAvatarLead] setActive:YES];;
    [[self.avatarImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                                     constant:kAvatarTrail] setActive:YES];;
    [[self.avatarImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                                constant:kAvatarTop] setActive:YES];
    [[self.avatarImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor
                                                   constant:kAvatarBottom] setActive:YES];
}

- (void)setNameLabelAnchor {
    [[self.nameLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                  constant:0] setActive:YES];
    [[self.nameLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                                   constant:0] setActive:YES];
    [[self.nameLabel.topAnchor constraintEqualToAnchor:self.avatarImageView.bottomAnchor
                                              constant:0] setActive:YES];
    [[self.nameLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor
                                                 constant:kNameLabelBottom] setActive:YES];
}

- (void)setNumberOfPhotosLabelAnchor {
    [[self.numberOfPhotosLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                    constant:0] setActive:YES];;
    [[self.numberOfPhotosLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                                     constant:0] setActive:YES];;
    [[self.numberOfPhotosLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor
                                                constant:0] setActive:YES];
    [[self.numberOfPhotosLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor
                                                   constant:0] setActive:YES];
}
#pragma mark - Custom accessors

- (UIImageView *)avatarImageView {
    if (_avatarImageView) return _avatarImageView;
//    _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kAvatarX,
//                                                                     kAvatarY,
//                                                                     kAvatarSize,
//                                                                     kAvatarSize)];
    _avatarImageView = [[UIImageView alloc] init];
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _avatarImageView.layer.cornerRadius = kAvatarSize / 2;
    _avatarImageView.layer.borderWidth = 1.0f;
    _avatarImageView.layer.borderColor = UIColor.whiteColor.CGColor;
    _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    _avatarImageView.image = [UIImage imageNamed:@"ic_person"];
    return _avatarImageView;
}

- (UILabel *)nameLabel {
    if (_nameLabel) return _nameLabel;
//    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kNameLabelX,
//                                                           kNameLabelY,
//                                                           kNameLabelWidth,
//                                                           kNameLabelHeight)];
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.textColor = UIColor.whiteColor;
    _nameLabel.text = @"Display name";
    return _nameLabel;
}

- (UILabel *)numberOfPhotosLabel {
    if (_numberOfPhotosLabel) return _numberOfPhotosLabel;
//    _numberOfPhotosLabel = [[UILabel alloc] initWithFrame:CGRectMake(kNumberOfPhotoLabelX,
//                                                                     kNumberOfPhotoLabelY,
//                                                                     kNumberOfPhotoLabelWidth,
//                                                                     kNumberOfPhotoLabelHeight)];
    _numberOfPhotosLabel = [[UILabel alloc] init];
    _numberOfPhotosLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _numberOfPhotosLabel.textAlignment = NSTextAlignmentCenter;
    _numberOfPhotosLabel.textColor = UIColor.whiteColor;
    _numberOfPhotosLabel.text = @"#Number Photos";
    return _numberOfPhotosLabel;

}

@end
