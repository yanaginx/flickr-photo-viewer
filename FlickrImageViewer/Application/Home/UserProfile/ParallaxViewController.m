//
//  ParallaxViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 10/07/2022.
//

#import "ParallaxViewController.h"
#import "UserProfileViewController.h"
#import "../UserProfile/SubViewControllers/HeaderViewController.h"
#import "../UserProfile/SubViewControllers/PublicPhotosViewController.h"
#import "../UserProfile/SubViewControllers/AlbumViewController.h"

#import "../../Main/AppDelegate.h"
#import "../../../Common/Utilities/AccountManager/AccountManager.h"
#import "../../../Common/Constants/Constants.h"
#import "../../../Common/Utilities/Scope/Scope.h"

@interface ParallaxViewController () <PublicPhotosRefreshDelegate, AlbumRefreshDelegate>

@property (nonatomic, strong) UserProfileViewController *userProfileViewController;
@property (nonatomic, strong) HeaderViewController *headerVC;
@property (nonatomic, strong) UIRefreshControl *refreshController;

@property (nonatomic, strong) UIAlertController *logoutModal;
@property (nonatomic, strong) UIBarButtonItem *settingButton;

@end

@implementation ParallaxViewController

- (void)dealloc {
    NSLog(@"[DEBUG] %s: did run!", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
}

#pragma mark - Public methods
- (void)refreshProfile {
    [self _refreshData];
    [self.headerVC reloadProfileInfo];
}

#pragma mark - Operations
- (void)_setupViews {
    [self _setupViewControllers];
    [self _setupSettingSection];
    [self _setupRefreshControl];
}

- (void)_setupViewControllers {
    self.headerViewController = self.headerVC;
    self.headerViewController.parallaxHeader.height = 150;
    self.headerViewController.parallaxHeader.minimumHeight = 0;
    self.childViewController = self.userProfileViewController;
    self.navigationController.navigationBar.tintColor = UIColor.blackColor;
}

- (void)_setupRefreshControl {
    [self.refreshController addTarget:self
                            action:@selector(refreshProfile)
                  forControlEvents:UIControlEventValueChanged];
    self.scrollView.refreshControl = self.refreshController;
    self.userProfileViewController.publicPhotoViewController.delegate = self;
    self.userProfileViewController.albumViewController.delegate = self;
    self.refreshController.layer.zPosition = self.scrollView.layer.zPosition + 1;
}

- (void)_refreshData {
    if (self.userProfileViewController.currentSubViewController == PublicPhotos) {
        [self.userProfileViewController.publicPhotoViewController getPhotosForFirstPage];
    } else {
        [self.userProfileViewController.albumViewController getAlbumsForFirstPage];
    }
    // refresh album infos instead
}

- (void)_refreshAllData {
    [self.userProfileViewController.publicPhotoViewController getPhotosForFirstPage];
    [self.userProfileViewController.albumViewController getAlbumsForFirstPage];
}

- (void)_setupSettingSection {
    [self _setupLogoutModal];
    [self _setupSettingButton];
}

- (void)_setupSettingButton {
    [self.navigationItem setRightBarButtonItem:self.settingButton animated:NO];
}

- (void)_setupLogoutModal {
    @weakify(self)
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Logout button menu", nil)
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self)
        [self _logout];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Logout cancel button menu", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [self.logoutModal addAction:action];
    [self.logoutModal addAction:cancelAction];
    self.logoutModal.preferredAction = action;
}

#pragma mark - PublicPhotosRefreshDelegate
- (void)cancelRefreshingAfterFetchingPublicPhotos {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshController endRefreshing];
    });
}

#pragma mark - AlbumRefreshDelegate
- (void)cancelRefreshingAfterFetchingAlbums {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshController endRefreshing];
    });
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
    _logoutModal = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Logout modal title", nil)
                                                       message:NSLocalizedString(@"Logout modal message", nil)
                                                preferredStyle:UIAlertControllerStyleAlert];
    return _logoutModal;
}

- (UIBarButtonItem *)settingButton {
    if (_settingButton) return _settingButton;
    @weakify(self)
    UIAction *logoutAction = [UIAction actionWithTitle:NSLocalizedString(@"Logout button menu", nil)
                                                 image:nil
                                            identifier:nil
                                               handler:^(__kindof UIAction * _Nonnull action) {
        @strongify(self)
        [self _onLogoutButtonClicked];
    }];
    UIMenu *settingMenu = [UIMenu menuWithChildren:@[logoutAction]];
    _settingButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_settings_outlined_big"]
                                                       menu:settingMenu];
    return _settingButton;
}

- (UIRefreshControl *)refreshController {
    if (_refreshController) return _refreshController;
    
    _refreshController = [[UIRefreshControl alloc] init];
    return _refreshController;
}

@end
