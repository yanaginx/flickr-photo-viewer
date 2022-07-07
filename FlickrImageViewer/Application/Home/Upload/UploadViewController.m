//
//  UploadViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import "UploadViewController.h"
#import "../../../Common/Constants/Constants.h"
#import "../../../Common/Utilities/Scope/Scope.h"

#import "../../Error/PermissionErrorViewController.h"
#import "UploadPostViewController.h"

#import "Views/GalleryCollectionViewCell.h"
#import "Handlers/GalleryManager.h"
#import "DataSource/GalleryDataSource.h"

@interface UploadViewController () <UICollectionViewDelegate, PermissionErrorViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) GalleryDataSource *dataSource;

@end

@implementation UploadViewController

static int rowCount = 3;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    [self registerLibraryObserver];
    [self checkPermission];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeLibraryObserver];
}

#pragma mark - Operations

- (void)checkPermission {
    @weakify(self)
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self showUIForAuthorizationStatus:status];
        });
    }];
}

- (void)showUIForAuthorizationStatus:(PHAuthorizationStatus)status {
    switch (status) {
        case PHAuthorizationStatusAuthorized:
            [self setupAuthorizedView];
            break;
        case PHAuthorizationStatusLimited:
            [self setupAuthorizedView];
            break;
        case PHAuthorizationStatusDenied:
            [self displayPermissionErrorView];
            break;
        default:
            break;
    }
}

- (void)setupAuthorizedView {
    [self setupTitle];
    [self setupNextButton];
    [self setupDismissButton];
    [self setupCollectionView];
}

- (void)setupTitle {
    self.navigationItem.title = @"Photo library";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
}

- (void)setupNextButton {
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(navigateToPostView)];
    [self.navigationItem setRightBarButtonItem:nextButton];
}

- (void)setupDismissButton {
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_cancel"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(dismiss)];
    [self.navigationItem setLeftBarButtonItem:dismissButton];
}

- (void)setupCollectionView {
    self.collectionView.frame = self.view.bounds;
    CGFloat cellWidth = (self.collectionView.frame.size.width - (2 * kMargin * ((CGFloat)rowCount - 1))) / (CGFloat)rowCount;
    CGSize targetSize = CGSizeMake(cellWidth, cellWidth);
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = targetSize;
    layout.minimumLineSpacing = kMargin;
    layout.minimumInteritemSpacing = kMargin;
    layout.sectionInset = UIEdgeInsetsMake(kMargin,
                                           kMargin,
                                           kMargin,
                                           kMargin);
    
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.prefetchDataSource = self.dataSource;
    self.collectionView.delegate = self;
    self.collectionView.allowsMultipleSelection = YES;
    
    [self.view addSubview:self.collectionView];
}

- (void)registerLibraryObserver {
    [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self.dataSource];
}

- (void)removeLibraryObserver {
    [PHPhotoLibrary.sharedPhotoLibrary unregisterChangeObserver:self.dataSource];
}



- (void)displayPermissionErrorView {
    dispatch_async(dispatch_get_main_queue(), ^{
        PermissionErrorViewController *permissionErrorVC = [[PermissionErrorViewController alloc] init];
        permissionErrorVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        permissionErrorVC.view.frame = self.view.bounds;
        permissionErrorVC.delegate = self;
        [self.navigationController pushViewController:permissionErrorVC animated:NO];
    });
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *photoAsset = [self.dataSource.galleryManager.fetchResult objectAtIndex:indexPath.item];
    [self.dataSource.selectedAssets setObject:photoAsset
                                       forKey:photoAsset.localIdentifier];
    NSLog(@"[DEBUG] %s: current selected count: %lu", __func__, (unsigned long)self.dataSource.selectedAssets.count);
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *photoAsset = [self.dataSource.galleryManager.fetchResult objectAtIndex:indexPath.item];
    [self.dataSource.selectedAssets removeObjectForKey:photoAsset.localIdentifier];
    NSLog(@"[DEBUG] %s: current selected count: %lu", __func__, (unsigned long)self.dataSource.selectedAssets.count);

}

#pragma mark - PermissionErrorViewDelegate
- (void)onRetryForPermissionErrorClicked {
    [self goToAppPrivacySettings];
}

- (void)goToAppPrivacySettings {
    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if (settingsURL == nil ||
        ![UIApplication.sharedApplication canOpenURL:settingsURL]) return;
    [UIApplication.sharedApplication openURL:settingsURL options:@{} completionHandler:nil];
}

#pragma mark - Handlers

- (void)navigateToPostView {
    UploadPostViewController *uploadPostVC = [[UploadPostViewController alloc] init];
    [self.navigationController pushViewController:uploadPostVC
                                         animated:YES];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Custom Accessors
- (UICollectionView *)collectionView {
    if (_collectionView) return _collectionView;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
   
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                         collectionViewLayout:layout];

    [_collectionView registerClass:[GalleryCollectionViewCell class]
        forCellWithReuseIdentifier:GalleryCollectionViewCell.reuseIdentifier];
    
    return _collectionView;

}

- (GalleryDataSource *)dataSource {
    if (_dataSource) return _dataSource;
    _dataSource = [[GalleryDataSource alloc] init];
    _dataSource.collectionView = self.collectionView;
    return _dataSource;
}


@end
