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
#import "Handlers/UploadPhotoManager.h"
#import "DataSource/GalleryDataSource.h"
#import "ViewModels/GalleryViewModel.h"

@interface UploadViewController () <UICollectionViewDelegate, PermissionErrorViewDelegate> {
    int rowCount;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) GalleryDataSource *dataSource;
@property (nonatomic, strong) UploadPhotoManager *uploadPhotoManager;
@property (nonatomic, strong) GalleryViewModel *galleryViewModel;

@end

@implementation UploadViewController

- (instancetype)initWithUploadPhotoManager:(UploadPhotoManager *)uploadManager {
    self = [self init];
    if (self) {
        self.uploadPhotoManager = uploadManager;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        rowCount = 3;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    [self _registerLibraryObserver];
    [self _checkPermission];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self _removeLibraryObserver];
}

#pragma mark - Operations

- (void)_checkPermission {
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
            [self _setupAuthorizedView];
            break;
        case PHAuthorizationStatusLimited:
            [self _setupAuthorizedView];
            break;
        case PHAuthorizationStatusDenied:
            [self _displayPermissionErrorView];
            break;
        default:
            break;
    }
}

- (void)_setupAuthorizedView {
    [self _setupTitle];
    [self _setupNextButton];
    [self _setupDismissButton];
    [self _setupCollectionView];
}

- (void)_setupTitle {
    self.navigationItem.title = @"Photo library";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
}

- (void)_setupNextButton {
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(_navigateToPostView)];
    [self.navigationItem setRightBarButtonItem:nextButton];
    [self _toggleNextButton];
}

- (void)_setupDismissButton {
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_cancel"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(_dismiss)];
    [self.navigationItem setLeftBarButtonItem:dismissButton];
}

- (void)_setupCollectionView {
    self.collectionView.frame = self.view.bounds;
    CGFloat cellWidth = (self.collectionView.frame.size.width - (kMargin * ((CGFloat)rowCount - 1))) / (CGFloat)rowCount;
    CGSize targetSize = CGSizeMake(cellWidth, cellWidth);
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = targetSize;
    layout.minimumLineSpacing = kMargin;
    layout.minimumInteritemSpacing = kMargin;
//    layout.sectionInset = UIEdgeInsetsMake(kMargin,
//                                           kMargin,
//                                           kMargin,
//                                           kMargin);
    
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.prefetchDataSource = self.dataSource;
    self.collectionView.delegate = self;
    self.collectionView.allowsMultipleSelection = YES;
    
    [self.view addSubview:self.collectionView];
}

- (void)_registerLibraryObserver {
    [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self.dataSource];
}

- (void)_removeLibraryObserver {
    [PHPhotoLibrary.sharedPhotoLibrary unregisterChangeObserver:self.dataSource];
}



- (void)_displayPermissionErrorView {
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
    [self _toggleNextButton];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *photoAsset = [self.dataSource.galleryManager.fetchResult objectAtIndex:indexPath.item];
    [self.dataSource.selectedAssets removeObjectForKey:photoAsset.localIdentifier];
    NSLog(@"[DEBUG] %s: current selected count: %lu", __func__, (unsigned long)self.dataSource.selectedAssets.count);
    [self _toggleNextButton];
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

- (void)_toggleNextButton {
    if (self.dataSource.selectedAssets.count > 0) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
}

- (void)_navigateToPostView {
    UploadPostViewController *uploadPostVC = [[UploadPostViewController alloc]
                                              initWithUploadPhotoManager:self.uploadPhotoManager
                                              galleryManager:self.dataSource.galleryManager];
    uploadPostVC.selectedAssets = self.dataSource.selectedAssets;
    [self.navigationController pushViewController:uploadPostVC
                                         animated:YES];
}

- (void)_dismiss {
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
