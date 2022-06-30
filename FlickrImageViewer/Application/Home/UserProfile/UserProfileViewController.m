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

#import "../../Main/AppDelegate.h"
#import "../../Login/Handlers/LoginHandler.h"

@interface UserProfileViewController ()

@property (nonatomic, strong) UIAlertController *logoutModal;
@property (nonatomic, strong) PublicPhotosViewController *publicPhotoViewController;
@property (nonatomic, strong) AlbumViewController *albumViewController;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    // Temporary logout button to test the flow
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(onLogoutButtonClicked)];
    [self.navigationItem setLeftBarButtonItem:logoutButton animated:YES];
    
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
    [self setupSegmentedControls];
    [self updateView];
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
    [[self.segmentedControl.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20] setActive:YES];
    
    self.segmentedControl.selectedSegmentIndex = 0;
}

- (void)addAsChildViewController:(UIViewController *)viewController {
    [self addChildViewController:viewController];
    
    [self.view addSubview:viewController.view];
    viewController.view.frame = CGRectMake(self.view.center.x - 200,
                                           self.view.center.y - 200,
                                           400,
                                           400);
    viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
        [self addAsChildViewController:self.publicPhotoViewController];
    } else {
        [self removeAsChildViewController:self.publicPhotoViewController];
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

- (UISegmentedControl *)segmentedControl {
    if (_segmentedControl) return _segmentedControl;

    _segmentedControl = [[UISegmentedControl alloc] init];
    return _segmentedControl;
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

@end

