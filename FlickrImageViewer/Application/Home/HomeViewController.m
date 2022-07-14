//
//  HomeViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import "HomeViewController.h"
#import "Upload/Handlers/UploadPhotoManager.h"
#import "../../Common/Constants/Constants.h"

@interface HomeViewController () <UploadPhotoManagerDelegate>

@property (nonatomic, strong) UploadPhotoManager *uploadManager;

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
    UIViewController *userVC = [[ParallaxViewController alloc] init];
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
    NSLog(@"[DEBUG] %s: Start uploading!", __func__);
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
            break;
    }
}

- (UploadPhotoManager *)uploadManager {
    if (_uploadManager) return _uploadManager;
    
    _uploadManager = [[UploadPhotoManager alloc] init];
    _uploadManager.delegate = self;
    return _uploadManager;
}

@end
