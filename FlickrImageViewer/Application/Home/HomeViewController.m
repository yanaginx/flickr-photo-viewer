//
//  HomeViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import "HomeViewController.h"
#import "Upload/Handlers/UploadPhotoManager.h"
#import "../../Common/Constants/Constants.h"
#import "../../Common/ViewComponents/SSSnackbar/SSSnackbar.h"

#define kPopularTabIndex 0
#define kUploadTabIndex 1
#define kProfileTabIndex 2
#define kUploadFinishSnackbarDuration 3

@interface HomeViewController () <UploadPhotoManagerDelegate>
//                                  UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) UploadPhotoManager *uploadManager;
@property (nonatomic, strong) ParallaxViewController *profileVC;

@end

@implementation HomeViewController

- (void)dealloc {
    NSLog(@"[DEBUG] %s: did run!", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    
    UIViewController *popularVC = [[PopularViewController alloc] init];
    UINavigationController *popularNavi = [[UINavigationController alloc] initWithRootViewController:popularVC];
    UIImage *popularIcon = [[UIImage imageNamed:@"ic_dashboard"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *popularIconOutlined = [[UIImage imageNamed:@"ic_dashboard_outlined"]
                                    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    popularVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Dashboard label", nil)
                                                         image:popularIconOutlined
                                                 selectedImage:popularIcon];
    
    UploadViewController *uploadVC = [[UploadViewController alloc] initWithUploadPhotoManager:self.uploadManager];
//    UINavigationController *uploadNavi = [[UINavigationController alloc] initWithRootViewController:uploadVC];
    UIImage *uploadIcon = [[UIImage imageNamed:@"ic_publish"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *uploadIconOutlined = [[UIImage imageNamed:@"ic_publish_outlined"]
                                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    uploadVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Upload label", nil)
                                                        image:uploadIconOutlined
                                                selectedImage:uploadIcon];
    
//    UIViewController *userVC = [[UserProfileViewController alloc] init];
//    UINavigationController *userNavi = [[UINavigationController alloc] initWithRootViewController:userVC];
//    UIImage *profileIcon = [[UIImage imageNamed:@"ic_person"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    UIImage *profileIconOutlined = [[UIImage imageNamed:@"ic_person_outlined"]
//                                    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    userVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Profile"
//                                                      image:profileIconOutlined
//                                              selectedImage:profileIcon];
    ParallaxViewController *userVC = [[ParallaxViewController alloc] init];
    self.profileVC = userVC;
    UINavigationController *userNavi = [[UINavigationController alloc] initWithRootViewController:userVC];
    UIImage *profileIcon = [[UIImage imageNamed:@"ic_person"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *profileIconOutlined = [[UIImage imageNamed:@"ic_person_outlined"]
                                    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    userVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Profile label", nil)
                                                      image:profileIconOutlined
                                              selectedImage:profileIcon];

    self.viewControllers = [NSArray arrayWithObjects:
                            popularNavi,
                            uploadVC,
                            userNavi,
                            nil];
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UploadViewController class]]) {
        UploadViewController *uploadVC = [[UploadViewController alloc] initWithUploadPhotoManager:self.uploadManager];
        UINavigationController *uploadNavi = [[UINavigationController alloc] initWithRootViewController:uploadVC];
        uploadNavi.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:uploadNavi animated:YES completion:nil];
        return NO;
    }
    return YES;
}

#pragma mark - UploadPhotoManagerDelegate
- (void)onUploadingWithNoInternet {
    [self _displayNoInternetStatus];
}

- (void)onStartUploadingImageWithTotalTasksCount:(NSInteger)totalTasks
                              finishedTasksCount:(NSInteger)finishedTasks {
    if (SSSnackbar.currentSnackbar == nil) {
        NSString *statusString = [NSString stringWithFormat:NSLocalizedString(@"Upload status ongoing with successful/total", nil),
                                  finishedTasks,
                                  totalTasks];
        [self _displayUploadingSnackbarWithStatusString:statusString];
    } else {
//        SSSnackbar.currentSnackbar setLabelText:@""
    }
    NSLog(@"[DEBUG] %s: Start uploading!", __func__);
    self.selectedViewController = [self.viewControllers objectAtIndex:kProfileTabIndex];
}

- (void)onFinishUploadingImageWithErrorCode:(NSInteger)errorCode
                            totalTasksCount:(NSInteger)totalTasks
                         finishedTasksCount:(NSInteger)finishedTasks {
    switch (errorCode) {
        case kNetworkError: {
            NSLog(@"[DEBUG] %s: Network error!", __func__);
            break;
        }
        case kServerError: {
            NSLog(@"[DEBUG] %s: Server error!", __func__);
            break;
        }
        case kNoDataError: {
            NSLog(@"[DEBUG] %s: No data error!", __func__);
            break;
        }
        case kNoError: {
            NSLog(@"[DEBUG] %s: Upload finished! Continuing...", __func__);
            NSString *statusString = [NSString stringWithFormat:NSLocalizedString(@"Upload status ongoing with succesful/total", nil),
                                      finishedTasks,
                                     totalTasks];
            [SSSnackbar.currentSnackbar setLabelText:statusString];
            break;
        }
        default: {
            NSLog(@"[DEBUG] %s: Upload finished for all images!", __func__);
            NSString *finishStatus = [NSString stringWithFormat:NSLocalizedString(@"Upload status finished with successful/total", nil),
                                     finishedTasks,
                                     totalTasks];
            // refresh profile upon finish uploading all
            [self.profileVC refreshProfile];
            [self _displayUploadFinishSnackbarWithStatusString:finishStatus];
            break;
        }
    }
}

#pragma mark - Private methods
- (void)_displayNoInternetStatus {
    SSSnackbar *snackbar = [SSSnackbar snackbarWithContextView:self.view
                                                       message:@"No internet, please try again later"
                                                    actionText:NSLocalizedString(@"Upload status close", nil)
                                                      duration:2
                                                   actionBlock:^(SSSnackbar *sender) {
        NSLog(@"[DEBUG] %s: snackbar close clicked!", __func__);
    }];
    [snackbar display];
}

- (void)_displayUploadingSnackbarWithStatusString:(NSString *)statusString {
//    NSString *snackbarMessage = [NSString stringWithFormat:@"Uploading... "];
    SSSnackbar *snackbar = [SSSnackbar snackbarWithContextView:self.view
                                                       message:statusString
                                                    actionText:NSLocalizedString(@"Upload status close", nil)
                                                      duration:SnackbarDurationInfinite
                                                   actionBlock:^(SSSnackbar *sender) {
        NSLog(@"[DEBUG] %s: snackbar close clicked!", __func__);
    }];
    [snackbar display];
}

- (void)_displayUploadFinishSnackbarWithStatusString:(NSString *)statusString {
    SSSnackbar *snackbar = [SSSnackbar snackbarWithContextView:self.view
                                                       message:statusString
                                                    actionText:NSLocalizedString(@"Upload status close", nil)
                                                      duration:3
                                                   actionBlock:^(SSSnackbar *sender) {
        NSLog(@"[DEBUG] %s: snackbar close clicked!", __func__);
    }];
    [snackbar display];
}

#pragma mark - Private methods
- (UIViewController *)topViewController{
  return [self topViewController:UIApplication.sharedApplication.delegate.window.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController {
  if (rootViewController.presentedViewController == nil) {
    return rootViewController;
  }
  
  if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
    UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
    UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
    return [self topViewController:lastViewController];
  }
  
  UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
  return [self topViewController:presentedViewController];
}


#pragma mark - Custom Accessors

- (UploadPhotoManager *)uploadManager {
    if (_uploadManager) return _uploadManager;
    
    _uploadManager = [[UploadPhotoManager alloc] init];
    _uploadManager.delegate = self;
    return _uploadManager;
}

@end
