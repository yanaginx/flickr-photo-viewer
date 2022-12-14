//
//  UserProfileViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 25/06/2022.
//

#import "UserProfileViewController.h"
#import "SubViewControllers/HeaderViewController.h"
#import "SubViewControllers/PublicPhotosViewController.h"
#import "SubViewControllers/AlbumViewController.h"
#import "UserProfileConstants.h"

#import "../../../Common/Extensions/UIView+Additions.h"
#import "../../../Common/Extensions/UISegmentedControl+Additions.h"
#import "../../Main/AppDelegate.h"
#import "../../../Common/Utilities/AccountManager/AccountManager.h"

@interface UserProfileViewController () {
    CurrentProfileSubViewController currentSubVC;
}

@property (nonatomic, strong) UIAlertController *logoutModal;
@property (nonatomic, strong) UIBarButtonItem *settingButton;

//@property (nonatomic, strong) HeaderViewController *headerViewController;
//@property (nonatomic, strong) PublicPhotosViewController *publicPhotoViewController;
//@property (nonatomic, strong) AlbumViewController *albumViewController;
@property (nonatomic, strong) UINavigationController *publicPhotoNavi;
@property (nonatomic, strong) UINavigationController *albumViewNavi;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@end

@implementation UserProfileViewController

- (void)dealloc {
    NSLog(@"[DEBUG] %s: did run!", __func__);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
//    [self.navigationItem setRightBarButtonItem:self.settingButton animated:NO];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
//                         forBarMetrics:UIBarMetricsDefault]; //UIImageNamed:@"transparent.png"
//    self.navigationController.navigationBar.shadowImage = [UIImage new];////UIImageNamed:@"transparent.png"
//    self.navigationController.navigationBar.translucent = YES;
//    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    [self _setupView];
}

- (CurrentProfileSubViewController)currentSubViewController {
    return currentSubVC;
}

#pragma mark - Handlers
//- (void)onLogoutButtonClicked {
//    [self presentViewController:self.logoutModal animated:YES completion:nil];
//}

- (void)onSegmentedSelectionChanged:(UISegmentedControl *)segment {
    [self.segmentedControl changeUnderlinePosition];
    [self _updateView];
}

#pragma mark - Private methods
- (void)_setupView {
//    [self setupHeader];
    [self _setupSegmentedControls];
    [self _updateView];
}

- (void)_setupHeader {
    [self addChildViewController:self.headerViewController];
    
    
    self.headerViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.headerViewController.view];
    
    [[self.headerViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[self.headerViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    [[self.headerViewController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                                              constant:kStatusBarHeight] setActive:YES];
    [[self.headerViewController.view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor
                                                                 constant:kHeaderBottomConstant] setActive:YES];
    self.headerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.headerViewController didMoveToParentViewController:self];
}

- (void)_setupSegmentedControls {
    [self.segmentedControl removeAllSegments];
    [self.segmentedControl insertSegmentWithTitle:NSLocalizedString(@"Profile public photo label", nil) atIndex:0 animated:NO];
    [self.segmentedControl insertSegmentWithTitle:NSLocalizedString(@"Profile album label", nil) atIndex:1 animated:NO];
    [self.segmentedControl addTarget:self
                              action:@selector(onSegmentedSelectionChanged:)
                    forControlEvents:UIControlEventValueChanged];
    
    self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.segmentedControl];
    
    [[self.segmentedControl.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[self.segmentedControl.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
//    [[self.segmentedControl.topAnchor constraintEqualToAnchor:self.headerViewController.view.bottomAnchor] setActive:YES];
//    [[self.segmentedControl.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor
//                                                     constant:self.navigationController.navigationBar.frame.size.height] setActive:YES];
    [[self.segmentedControl.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                                     constant:0] setActive:YES];
//    [[self.segmentedControl.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor
//                                                        constant:kSegmentedControlBottomConstant] setActive:YES];
    [self.segmentedControl layoutIfNeeded];
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addUnderlineForSelectedSegment];

}

- (void)_addAsChildViewController:(UIViewController *)viewController {
    [self addChildViewController:viewController];
    
    [self.view addSubview:viewController.view];
    
    viewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [[viewController.view.topAnchor constraintEqualToAnchor:self.segmentedControl.bottomAnchor] setActive:YES];
//    NSLog(@"[DEBUG] segmented control height: %f", self.segmentedControl.frame.size.height);
    [[viewController.view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor] setActive:YES];
    [[viewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[viewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    [viewController didMoveToParentViewController:self];
}

- (void)_removeAsChildViewController:(UIViewController *)viewController {
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (void)_updateView {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
//        [self removeAsChildViewController:self.albumViewController];
        [self _removeAsChildViewController:self.albumViewNavi];
        [self _addAsChildViewController:self.publicPhotoNavi];
        currentSubVC = PublicPhotos;
    } else {
        [self _removeAsChildViewController:self.publicPhotoNavi];
//        [self addAsChildViewController:self.albumViewController];
        [self _addAsChildViewController:self.albumViewNavi];
        currentSubVC = Albums;
    }
}


- (void)_logout {
    /// Navigate to Login Screen
    [AccountManager removeAccountInfo];
    [AppDelegate.shared updateView];
}

#pragma mark - Custom accessors
//- (UIAlertController *)logoutModal {
//    if (_logoutModal) return _logoutModal;
//
//    _logoutModal = [UIAlertController alertControllerWithTitle:@"Hope to see you soon"
//                                                       message:@"Are you sure you want to logout?"
//                                                preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Log out"
//                                                     style:UIAlertActionStyleDestructive
//                                                   handler:^(UIAlertAction * _Nonnull action) {
//        [self _logout];
//    }];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
//                                                           style:UIAlertActionStyleCancel
//                                                         handler:nil];
//    [_logoutModal addAction:action];
//    [_logoutModal addAction:cancelAction];
//    _logoutModal.preferredAction = action;
//    return _logoutModal;
//}
//
//- (UIBarButtonItem *)settingButton {
//    if (_settingButton) return _settingButton;
//    UIAction *logoutAction = [UIAction actionWithTitle:@"Logout"
//                                                 image:nil
//                                            identifier:nil
//                                               handler:^(__kindof UIAction * _Nonnull action) {
//        [self _onLogoutButtonClicked];
//    }];
//    UIMenu *settingMenu = [UIMenu menuWithChildren:@[logoutAction]];
//    _settingButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_settings"]
//                                                       menu:settingMenu];
//    return _settingButton;
//}

- (UISegmentedControl *)segmentedControl {
    if (_segmentedControl) return _segmentedControl;

    _segmentedControl = [[UISegmentedControl alloc] init];
    return _segmentedControl;
}

- (HeaderViewController *)headerViewController {
    if (_headerViewController) return _headerViewController;
    
    _headerViewController = [[HeaderViewController alloc] init];
    return _headerViewController;
}

- (PublicPhotosViewController *)publicPhotoViewController {
    if (_publicPhotoViewController) return _publicPhotoViewController;
    
    _publicPhotoViewController = [[PublicPhotosViewController alloc] init];
    return _publicPhotoViewController;
}

- (AlbumViewController *)albumViewController {
    if (_albumViewController) return _albumViewController;
    
    _albumViewController = [[AlbumViewController alloc] init];
    _albumViewController.profileNavigationController = self.navigationController;
    return _albumViewController;
}

- (UINavigationController *)publicPhotoNavi {
    if (_publicPhotoNavi) return _publicPhotoNavi;
    _publicPhotoNavi = [[UINavigationController alloc] initWithRootViewController:self.publicPhotoViewController];
    return _publicPhotoNavi;
}

- (UINavigationController *)albumViewNavi {
    if (_albumViewNavi) return _albumViewNavi;
    _albumViewNavi = [[UINavigationController alloc] initWithRootViewController:self.albumViewController];
    return _albumViewNavi;
}

@end

