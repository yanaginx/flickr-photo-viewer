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

@property (nonatomic, strong) UserProfileManager *userProfileManager;

@end

@implementation HeaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
//    if ([self.nameLabel.text isEqualToString:@"Display name"]) {
    [self _getUserProfile];
//    }
}

//- (void)viewWillLayoutSubviews {
//    NSLog(@"[DEBUG] %s: %f", __func__, self.view.frame.size.height);
//    NSLog(@"[DEBUG] %s: %f", __func__, self.view.frame.size.width);
//}

#pragma mark - Operations
- (void)_getUserProfile {
    [self.userProfileManager getUserProfileWithCompletionHandler:^(NSURL * _Nullable avatarURL,
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
        
        [self _configureNameWithString:name];
        [self _configureAvatarWithImageURL:avatarURL];
        [self _configureNumberOfPhotosWithString:numberOfPhotos];
    }];
}

#pragma mark - Views setup
- (void)_setupViews {
    self.view.backgroundColor = UIColor.whiteColor;
    [self _setupAvatarImageView];
    [self _setupNameLabel];
    [self _setupNumberOfPhotosLabel];
}

- (void)_setupAvatarImageView {
    [self.view addSubview:self.avatarImageView];
    self.avatarImageView.frame = CGRectMake(kAvatarX,
                                            kAvatarY + self._statusBarHeight,
                                            kAvatarSize,
                                            kAvatarSize);
    self.avatarImageView.layer.cornerRadius = kAvatarSize / 2;
    self.avatarImageView.layer.borderWidth = 1.0f;
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.borderColor = kAppleBlue.CGColor;
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarImageView.image = [UIImage imageNamed:@"ic_person"];
}

- (void)_setupNameLabel {
    // TODO: Setup the name label frame
    [self.view addSubview:self.nameLabel];
    self.nameLabel.frame = CGRectMake(kNameLabelX,
                                      kNameLabelY + self._statusBarHeight,
                                      kNameLabelWidth,
                                      kNameLabelHeight);
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
//    self.nameLabel.textColor = kAppleBlue;
    self.nameLabel.text = @"Display name";
}

- (void)_setupNumberOfPhotosLabel {
    // TODO: Setup the number of photos label frame
    [self.view addSubview:self.numberOfPhotosLabel];
    self.numberOfPhotosLabel.frame = CGRectMake(kNumberOfPhotoLabelX,
                                                kNumberOfPhotoLabelY + self._statusBarHeight,
                                                kNumberOfPhotoLabelWidth,
                                                kNumberOfPhotoLabelHeight);
    self.numberOfPhotosLabel.textAlignment = NSTextAlignmentCenter;
//    self.numberOfPhotosLabel.textColor = ;
    self.numberOfPhotosLabel.text = @"#Number Photos";
}

#pragma mark - Helpers

- (void)_configureAvatarWithImageURL:(NSURL *)avatarImageURL {
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.avatarImageView.image = UIImage imageNamed:@"ic_"
        [self.avatarImageView setImageUsingURL:avatarImageURL];
    });
}

- (void)_configureNameWithString:(NSString *)nameString {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.nameLabel.text = nameString;
    });
}

- (void)_configureNumberOfPhotosWithString:(NSString *)numberOfPhotos {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.numberOfPhotosLabel.text = [NSString stringWithFormat:@"%@ Photos", numberOfPhotos];
    });
}

- (void)_setAvatarImageViewAnchor {
    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.avatarImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                    constant:kAvatarLead] setActive:YES];;
    [[self.avatarImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                                     constant:kAvatarTrail] setActive:YES];;
    [[self.avatarImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                                constant:kAvatarTop] setActive:YES];
    [[self.avatarImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor
                                                   constant:kAvatarBottom] setActive:YES];
}

- (void)_setNameLabelAnchor {
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.nameLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                  constant:0] setActive:YES];
    [[self.nameLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                                   constant:0] setActive:YES];
    [[self.nameLabel.topAnchor constraintEqualToAnchor:self.avatarImageView.bottomAnchor
                                              constant:0] setActive:YES];
    [[self.nameLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor
                                                 constant:kNameLabelBottom] setActive:YES];
}

- (void)_setNumberOfPhotosLabelAnchor {
    self.numberOfPhotosLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.numberOfPhotosLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                    constant:0] setActive:YES];;
    [[self.numberOfPhotosLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                                     constant:0] setActive:YES];;
    [[self.numberOfPhotosLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor
                                                constant:0] setActive:YES];
    [[self.numberOfPhotosLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor
                                                   constant:kNumberOfPhotoBottom] setActive:YES];
}

- (CGFloat)_statusBarHeight {
    UIWindowScene * scene = nil;
    for (UIWindowScene* wScene in [UIApplication sharedApplication].connectedScenes){
        if (wScene.activationState == UISceneActivationStateForegroundActive){
            scene = wScene;
            break;
        }
    }
    CGFloat statusBarHeight = scene.statusBarManager.statusBarFrame.size.height;
    return statusBarHeight;
}

#pragma mark - Custom accessors

- (UIImageView *)avatarImageView {
    if (_avatarImageView) return _avatarImageView;
    _avatarImageView = [[UIImageView alloc] init];

    return _avatarImageView;
}

- (UILabel *)nameLabel {
    if (_nameLabel) return _nameLabel;
    _nameLabel = [[UILabel alloc] init];

    return _nameLabel;
}

- (UILabel *)numberOfPhotosLabel {
    if (_numberOfPhotosLabel) return _numberOfPhotosLabel;
    _numberOfPhotosLabel = [[UILabel alloc] init];

    return _numberOfPhotosLabel;

}

- (UserProfileManager *)userProfileManager {
    if (_userProfileManager) return _userProfileManager;
    
    _userProfileManager = [[UserProfileManager alloc] init];
    return _userProfileManager;
}

@end
