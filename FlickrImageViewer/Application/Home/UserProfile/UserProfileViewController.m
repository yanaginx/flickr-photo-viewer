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
#import "../../Main/AppDelegate.h"
#import "../../Login/Handlers/LoginHandler.h"

@interface UserProfileViewController ()

@property (nonatomic, strong) UIAlertController *logoutModal;
@property (nonatomic, strong) UIBarButtonItem *settingButton;

@property (nonatomic, strong) HeaderViewController *headerViewController;
@property (nonatomic, strong) PublicPhotosViewController *publicPhotoViewController;
@property (nonatomic, strong) AlbumViewController *albumViewController;
@property (nonatomic, strong) UINavigationController *publicPhotoNavi;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
//     Temporary logout button to test the flow
//    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
//                                                                     style:UIBarButtonItemStylePlain
//                                                                    target:self
//                                                                    action:@selector(onLogoutButtonClicked)];
    
//    [self.navigationItem setLeftBarButtonItem:logoutButton animated:YES];
    [self.navigationItem setRightBarButtonItem:self.settingButton animated:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                         forBarMetrics:UIBarMetricsDefault]; //UIImageNamed:@"transparent.png"
    self.navigationController.navigationBar.shadowImage = [UIImage new];////UIImageNamed:@"transparent.png"
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    [self setupView];
}

#pragma mark - Handlers
- (void)onLogoutButtonClicked {
    [self presentViewController:self.logoutModal animated:YES completion:nil];
}

- (void)onSegmentedSelectionChanged:(UISegmentedControl *)segment {
    [self updateView];
}

#pragma mark - Private methods
- (void)setupView {
    [self setupHeader];
    [self setupSegmentedControls];
    [self updateView];
}

- (void)setupHeader {
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

- (void)setupSegmentedControls {
    [self.segmentedControl removeAllSegments];
    [self.segmentedControl insertSegmentWithTitle:@"Public photos" atIndex:0 animated:NO];
    [self.segmentedControl insertSegmentWithTitle:@"Album" atIndex:1 animated:NO];
    [self.segmentedControl addTarget:self
                              action:@selector(onSegmentedSelectionChanged:)
                    forControlEvents:UIControlEventValueChanged];
    
    self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.segmentedControl];
    
    [[self.segmentedControl.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[self.segmentedControl.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    [[self.segmentedControl.topAnchor constraintEqualToAnchor:self.headerViewController.view.bottomAnchor] setActive:YES];
    [[self.segmentedControl.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor
                                                        constant:kSegmentedControlBottomConstant] setActive:YES];
    
    self.segmentedControl.selectedSegmentIndex = 0;
}

- (void)addAsChildViewController:(UIViewController *)viewController {
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

- (void)removeAsChildViewController:(UIViewController *)viewController {
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (void)updateView {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self removeAsChildViewController:self.albumViewController];
        [self addAsChildViewController:self.publicPhotoNavi];
    } else {
        [self removeAsChildViewController:self.publicPhotoNavi];
        [self addAsChildViewController:self.albumViewController];
    }
}


- (void)logout {
    [LoginHandler.sharedLoginHandler removeUserAccessTokenAndSecret];
    /// Navigate to Login Screen
    [AppDelegate.shared.rootViewController switchToLogOut];
}

#pragma mark - Custom accessors
- (UIAlertController *)logoutModal {
    if (_logoutModal) return _logoutModal;
    
    _logoutModal = [UIAlertController alertControllerWithTitle:@"Hope to see you soon"
                                                       message:@"Are you sure you want to logout?"
                                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Log out"
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction * _Nonnull action) {
        [self logout];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [_logoutModal addAction:action];
    [_logoutModal addAction:cancelAction];
    _logoutModal.preferredAction = action;
    return _logoutModal;
}

- (UIBarButtonItem *)settingButton {
    if (_settingButton) return _settingButton;
    UIAction *logoutAction = [UIAction actionWithTitle:@"Logout"
                                                 image:nil
                                            identifier:nil
                                               handler:^(__kindof UIAction * _Nonnull action) {
        [self onLogoutButtonClicked];
    }];
    UIMenu *settingMenu = [UIMenu menuWithChildren:@[logoutAction]];
    _settingButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_settings"]
                                                                       menu:settingMenu];
    return _settingButton;
}

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
    return _albumViewController;
}

- (UINavigationController *)publicPhotoNavi {
    if (_publicPhotoNavi) return _publicPhotoNavi;
    _publicPhotoNavi = [[UINavigationController alloc] initWithRootViewController:self.publicPhotoViewController];
    return _publicPhotoNavi;
}

@end

