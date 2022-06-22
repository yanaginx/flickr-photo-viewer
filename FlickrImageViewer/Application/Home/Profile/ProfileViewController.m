//
//  ProfileViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import "ProfileViewController.h"
#import "../../Main/AppDelegate.h"
#import "../../Login/Handlers/LoginHandler.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.magentaColor;
    // Temporary logout button to test the flow
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(logout)];
    [self.navigationItem setLeftBarButtonItem:logoutButton animated:YES];
}


#pragma mark - Private methods
- (void)logout {
    [LoginHandler.sharedLoginHandler removeUserAccessTokenAndSecret];
    /// Navigate to Login Screen
    [AppDelegate.shared.rootViewController switchToLogOut];
}

@end
