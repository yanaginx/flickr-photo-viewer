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
                                                                    action:@selector(logout)];
    [self.navigationItem setLeftBarButtonItem:logoutButton animated:YES];
}


//#pragma mark - Private methods
- (void)logout {
    [LoginHandler.sharedLoginHandler removeUserAccessTokenAndSecret];
    /// Navigate to Login Screen
    [AppDelegate.shared.rootViewController switchToLogOut];
}

@end

