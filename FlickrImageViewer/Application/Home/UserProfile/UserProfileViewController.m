//
//  UserProfileViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 25/06/2022.
//

#import "UserProfileViewController.h"
#import "../../Main/AppDelegate.h"
#import "../../Login/Handlers/LoginHandler.h"

@interface UserProfileViewController ()

@property (nonatomic, strong) UIAlertController *logoutModal;

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
}

#pragma mark - Handlers
- (void)onLogoutButtonClicked {
    [self presentViewController:self.logoutModal animated:YES completion:nil];
}

#pragma mark - Private methods
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

@end

