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

//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        self.uploadManager = [[UploadPhotoManager alloc] init];
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    
    UIViewController *popularVC = [[PopularViewController alloc] init];
    UINavigationController *popularNavi = [[UINavigationController alloc] initWithRootViewController:popularVC];
    UIImage *popularIcon = [[UIImage imageNamed:@"ic_dashboard"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *popularIconOutlined = [[UIImage imageNamed:@"ic_dashboard_outlined"]
                                    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    popularVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Dashboard"
                                                         image:popularIconOutlined
                                                 selectedImage:popularIcon];
    
    UploadViewController *uploadVC = [[UploadViewController alloc] initWithUploadPhotoManager:self.uploadManager];
//    UINavigationController *uploadNavi = [[UINavigationController alloc] initWithRootViewController:uploadVC];
    UIImage *uploadIcon = [[UIImage imageNamed:@"ic_publish"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *uploadIconOutlined = [[UIImage imageNamed:@"ic_publish_outlined"]
                                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    uploadVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Upload"
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
    userVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Profile"
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
- (void)onStartUploadingImage {
    [self _displayUploadingSnackbar];
    NSLog(@"[DEBUG] %s: Start uploading!", __func__);
    self.selectedViewController = [self.viewControllers objectAtIndex:kProfileTabIndex];
}

- (void)onFinishUploadingImageWithErrorCode:(NSInteger)errorCode {
    switch (errorCode) {
        case kNetworkError:
            NSLog(@"[DEBUG] %s: Network error!", __func__);
            break;
        case kServerError:
            NSLog(@"[DEBUG] %s: Server error!", __func__);
            break;
        case kNoDataError:
            NSLog(@"[DEBUG] %s: No data error!", __func__);
            break;
        case kNoError:
            NSLog(@"[DEBUG] %s: Upload finished! Continuing...", __func__);
            break;
        default:
            NSLog(@"[DEBUG] %s: Upload finished for all images!", __func__);
            // refresh profile upon finish uploading all
            [self.profileVC refreshProfile];
            [self _displayUploadFinishSnackbar];
            break;
    }
}

#pragma mark - Private methods
//- (void)_setupUploadPopover {
//    UploadStatusViewController *uploadStatusVC = [[UploadStatusViewController alloc] init];
//    uploadStatusVC.modalPresentationStyle = UIModalPresentationPopover;
//
//    uploadStatusVC.popoverPresentationController.delegate = self;
//    uploadStatusVC.popoverPresentationController.sourceView = self.tabBar;
//    uploadStatusVC.popoverPresentationController.sourceRect = [self _frameForTabWithIndex:kProfileTabIndex];
//    uploadStatusVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
//    NSMutableArray *passthroughViews = [NSMutableArray array];
//    [passthroughViews addObject:self.tabBar];
//    for (UIViewController *viewController in self.viewControllers) {
//        [passthroughViews addObject:viewController.view];
//    }
//    for (UITabBarItem *tabBarItem in self.tabBar.items) {
//        [passthroughViews addObject:[tabBarItem valueForKey:@"view"]];
//    }
//    uploadStatusVC.popoverPresentationController.passthroughViews = passthroughViews;
//    [self presentViewController:uploadStatusVC animated:YES completion:nil];
//}
//
//- (CGRect)_frameForTabWithIndex:(NSUInteger)index {
//    UIView *tabBarItemView = [self.tabBar.items[index] valueForKey:@"view"];
//    if (tabBarItemView == nil) return CGRectZero;
//    CGRect tabBarItemFrame = tabBarItemView.frame;
//    return tabBarItemFrame;
//}

- (void)_displayUploadingSnackbar {
    NSString *snackbarMessage = [NSString stringWithFormat:@"Uploading..."];
    SSSnackbar *snackbar = [SSSnackbar snackbarWithContextView:self.view
                                                       message:snackbarMessage
                                                    actionText:@"CLOSE"
                                                      duration:SnackbarDurationInfinite
                                                   actionBlock:^(SSSnackbar *sender) {
        NSLog(@"[DEBUG] %s: snackbar close clicked!", __func__);
    }];
    [snackbar display];
}

- (void)_displayUploadFinishSnackbar {
    NSString *snackbarMessage = [NSString stringWithFormat:@"Uploaded!"];
    SSSnackbar *snackbar = [SSSnackbar snackbarWithContextView:self.view
                                                       message:snackbarMessage
                                                    actionText:@"CLOSE"
                                                      duration:3
                                                   actionBlock:^(SSSnackbar *sender) {
        NSLog(@"[DEBUG] %s: snackbar close clicked!", __func__);
    }];
    [snackbar display];
}
//#pragma mark - UIPopoverPresentationControllerDelegate
//- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
//    return UIModalPresentationNone;
//}

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
