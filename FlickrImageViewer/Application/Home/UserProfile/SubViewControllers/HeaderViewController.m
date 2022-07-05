//
//  HeaderViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 30/06/2022.
//

#import "HeaderViewController.h"
#import "../UserProfileConstants.h"
#import "../../../../Common/Constants/Constants.h"
#import "../../../../Common/Extensions/UIImageView+Additions.h"
#import "../Handlers/UserProfileManager.h"

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

- (void)viewWillAppear:(BOOL)animated {
    if ([self.nameLabel.text isEqualToString:@"Display name"]) {
        [self getUserProfile];
    }
}

- (void)viewWillLayoutSubviews {
    [self.view addSubview:self.avatarImageView];
    [self setAvatarImageViewAnchor];
    [self.view addSubview:self.nameLabel];
    [self setNameLabelAnchor];
    [self.view addSubview:self.numberOfPhotosLabel];
    [self setNumberOfPhotosLabelAnchor];
//    NSLog(@"[DEBUG] %s: %f", __func__, self.view.frame.size.height);
//    NSLog(@"[DEBUG] %s: %f", __func__, self.view.frame.size.width);
}

#pragma mark - Operations
- (void)getUserProfile {
    [UserProfileManager.sharedUserProfileManager getUserProfileWithCompletionHandler:^(NSURL * _Nullable avatarURL,
                                                                                       NSString * _Nullable name,
                                                                                       NSString * _Nullable numberOfPhotos,
                                                                                       NSError * _Nullable error) {

        NSLog(@"[DEBUG] %s : API called!", __func__);
        if (error) {
            switch (error.code) {
                case kNetworkError:
                    // Network error view
                    NSLog(@"[DEBUG] %s : No internet connection", __func__);
                    break;
                case kNoDataError:
                    // No data error view
                    NSLog(@"[DEBUG] %s : No data error, try again", __func__);
                    break;
                default:
                    // Error occur view
                    NSLog(@"[DEBUG] %s : Something went wrong", __func__);
                    break;
            }
            return;
        }
        
        [self configureNameWithString:name];
        [self configureAvatarWithImageURL:avatarURL];
        [self configureNumberOfPhotosWithString:numberOfPhotos];
    }];
}

#pragma mark - Helpers

- (void)configureAvatarWithImageURL:(NSURL *)avatarImageURL {
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.avatarImageView.image = UIImage imageNamed:@"ic_"
        [self.avatarImageView setImageUsingURL:avatarImageURL];
    });
}

- (void)configureNameWithString:(NSString *)nameString {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.nameLabel.text = nameString;
    });
}

- (void)configureNumberOfPhotosWithString:(NSString *)numberOfPhotos {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.numberOfPhotosLabel.text = [NSString stringWithFormat:@"%@ Photos", numberOfPhotos];
    });
}

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
                                                   constant:kNumberOfPhotoBottom] setActive:YES];
}
#pragma mark - Custom accessors

- (UIImageView *)avatarImageView {
    if (_avatarImageView) return _avatarImageView;
    _avatarImageView = [[UIImageView alloc] init];
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _avatarImageView.layer.cornerRadius = kAvatarSize / 2;
    _avatarImageView.layer.borderWidth = 1.0f;
    _avatarImageView.layer.masksToBounds = YES;
    _avatarImageView.layer.borderColor = UIColor.whiteColor.CGColor;
    _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    _avatarImageView.image = [UIImage imageNamed:@"ic_person"];
    return _avatarImageView;
}

- (UILabel *)nameLabel {
    if (_nameLabel) return _nameLabel;
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.textColor = UIColor.whiteColor;
    _nameLabel.text = @"Display name";
    return _nameLabel;
}

- (UILabel *)numberOfPhotosLabel {
    if (_numberOfPhotosLabel) return _numberOfPhotosLabel;
    _numberOfPhotosLabel = [[UILabel alloc] init];
    _numberOfPhotosLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _numberOfPhotosLabel.textAlignment = NSTextAlignmentCenter;
    _numberOfPhotosLabel.textColor = UIColor.whiteColor;
    _numberOfPhotosLabel.text = @"#Number Photos";
    return _numberOfPhotosLabel;

}

@end
