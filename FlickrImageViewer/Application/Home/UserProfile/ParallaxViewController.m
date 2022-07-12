//
//  ParallaxViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 10/07/2022.
//

#import "ParallaxViewController.h"
#import "UserProfileViewController.h"
#import "../UserProfile/SubViewControllers/HeaderViewController.h"

#import "../../Main/AppDelegate.h"
#import "../../../Common/Utilities/AccountManager/AccountManager.h"
#import "../../../Common/Constants/Constants.h"

@interface ParallaxViewController ()

@property (nonatomic, strong) UserProfileViewController *userProfileViewController;
@property (nonatomic, strong) HeaderViewController *headerVC;

@property (nonatomic, strong) UIAlertController *logoutModal;
@property (nonatomic, strong) UIBarButtonItem *settingButton;

@end

@implementation ParallaxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
}

#pragma mark - Operations
- (void)_setupViews {
    [self _setupViewControllers];
    [self _setupSettingSection];
}

- (void)_setupViewControllers {
    self.headerViewController = self.headerVC;
    self.headerViewController.parallaxHeader.height = 150;
    self.headerViewController.parallaxHeader.minimumHeight = 0;
    self.childViewController = self.userProfileViewController;
    self.navigationController.navigationBar.tintColor = UIColor.blackColor;
}

- (void)_setupSettingSection {
    [self _setupLogoutModal];
    [self _setupSettingButton];
}

- (void)_setupSettingButton {
    [self.navigationItem setRightBarButtonItem:self.settingButton animated:NO];
}

- (void)_setupLogoutModal {
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Log out"
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction * _Nonnull action) {
        [self _logout];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [self.logoutModal addAction:action];
    [self.logoutModal addAction:cancelAction];
    self.logoutModal.preferredAction = action;
}


#pragma mark - Handlers
- (void)_logout {
    /// Navigate to Login Screen
    [AccountManager removeAccountInfo];
    [AppDelegate.shared updateView];
}

- (void)_onLogoutButtonClicked {
    [self presentViewController:self.logoutModal animated:YES completion:nil];
}

#pragma mark - Custom Accessors
- (UserProfileViewController *)userProfileViewController {
    if (_userProfileViewController) return _userProfileViewController;
    
    _userProfileViewController = [[UserProfileViewController alloc] init];
    return _userProfileViewController;
}

- (HeaderViewController *)headerVC {
    if (_headerVC) return _headerVC;
    
    _headerVC = [[HeaderViewController alloc] init];
    return _headerVC;
}

- (UIAlertController *)logoutModal {
    if (_logoutModal) return _logoutModal;
    _logoutModal = [UIAlertController alertControllerWithTitle:@"Hope to see you soon"
                                                       message:@"Are you sure you want to logout?"
                                                preferredStyle:UIAlertControllerStyleAlert];
    return _logoutModal;
}

- (UIBarButtonItem *)settingButton {
    if (_settingButton) return _settingButton;
    UIAction *logoutAction = [UIAction actionWithTitle:@"Logout"
                                                 image:nil
                                            identifier:nil
                                               handler:^(__kindof UIAction * _Nonnull action) {
        [self _onLogoutButtonClicked];
    }];
    UIMenu *settingMenu = [UIMenu menuWithChildren:@[logoutAction]];
    _settingButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_settings_outlined_big"]
                                                       menu:settingMenu];
    return _settingButton;
}

@end
