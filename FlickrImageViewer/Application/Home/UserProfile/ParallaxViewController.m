//
//  ParallaxViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 10/07/2022.
//

#import "ParallaxViewController.h"
#import "UserProfileViewController.h"
#import "../UserProfile/SubViewControllers/HeaderViewController.h"

@interface ParallaxViewController ()

@property (nonatomic, strong) UserProfileViewController *userProfileViewController;
@property (nonatomic, strong) HeaderViewController *headerVC;

@end

@implementation ParallaxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.headerViewController = self.headerVC;
    self.headerViewController.parallaxHeader.height = 150;
    self.headerViewController.parallaxHeader.minimumHeight = 0;
    self.childViewController = self.userProfileViewController;
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

@end
