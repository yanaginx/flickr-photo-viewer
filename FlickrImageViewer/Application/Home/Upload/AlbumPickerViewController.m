//
//  AlbumPickerViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 08/07/2022.
//

#import "AlbumPickerViewController.h"
#import "../../../Common/Layouts/FixedLayout/FixedFlowLayout.h"
#import "../../../Common/Constants/Constants.h"

#import "../../../Models/AlbumInfo.h"
#import "../../Home/UserProfile/Handlers/AlbumInfoManager.h"
#import "../../Home/UserProfile/Views/AlbumInfoCollectionViewCell.h"
#import "../../Home/UserProfile/SubViewControllers/DataSource/AlbumInfoDataSource.h"

#import "../../Error/NetworkErrorViewController.h"
#import "../../Error/ServerErrorViewController.h"
#import "../../Error/NoDataErrorViewController.h"

@interface AlbumPickerViewController () <UICollectionViewDelegate,
                                         UICollectionViewDelegateFlowLayout,
                                         NetworkErrorViewDelegate,
                                         ServerErrorViewDelegate,
                                         NoDataErrorViewDelegate> {
    NSInteger currentPage;
    BOOL isLastPage;
    NSInteger numOfPhotosBeforeNewFetch;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) FixedFlowLayout *fixedFlowLayout;
@property (nonatomic, strong) AlbumInfoDataSource *dataSource;
@property (nonatomic, strong) AlbumInfoManager *albumInfoManager;
@property (nonatomic, strong) AlbumInfo *selectedAlbumInfo;

@property (nonatomic, strong) NetworkErrorViewController *networkErrorViewController;
@property (nonatomic, strong) NoDataErrorViewController *noDataErrorViewController;
@property (nonatomic, strong) ServerErrorViewController *serverErrorViewController;

@end

@implementation AlbumPickerViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        currentPage = 1;
        isLastPage = NO;
        numOfPhotosBeforeNewFetch = 1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    if (currentPage != 1) currentPage = 1;
    [self _getAlbumInfosForPage:currentPage];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews {
    self.collectionView.frame = CGRectMake(self.view.bounds.origin.x,
                                           self.view.bounds.origin.y,
                                           self.view.bounds.size.width,
                                           self.view.bounds.size.height);
    self.fixedFlowLayout.itemSize = CGSizeMake(self.collectionView.bounds.size.width -
                                               _fixedFlowLayout.minimumLineSpacing * 2,
                                               kMaxRowHeight - _fixedFlowLayout.minimumLineSpacing * 2);
}


#pragma mark - Operations
- (void)setupViews {
    [self _setupCollectionView];
    [self _setupSaveButton];
}

- (void)_setupCollectionView {
    self.collectionView.backgroundColor = UIColor.lightGrayColor;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.delegate = self;
    self.collectionView.allowsMultipleSelection = NO;
    [self.view addSubview:self.collectionView];
}

- (void)_setupSaveButton {
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(_saveAlbumIDAndDismiss)];
    [self.navigationItem setRightBarButtonItem:saveButton];
    [self _toggleSaveButton];
}

- (void)_saveAlbumIDAndDismiss {
    [self.delegate onFinishSelectAlbumInfo:self.selectedAlbumInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_toggleSaveButton {
    if (self.selectedAlbumInfo) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
}

- (void)_getAlbumInfosForPage:(NSInteger)pageNum {
   [self.albumInfoManager getUserAlbumInfosWithPage:pageNum
                                  completionHandler:^(NSMutableArray<AlbumInfo *> * _Nullable albumInfos,
                                                                                NSError * _Nullable error) {
        
        NSLog(@"[DEBUG] %s : API called!", __func__);
        if (error) {
            switch (error.code) {
                case kNetworkError:
                    // Network error view
                    NSLog(@"[DEBUG] %s : No internet connection", __func__);
                    [self _viewNetworkError];
                    break;
                case kNoDataError:
                    // No data error view
                    NSLog(@"[DEBUG] %s : No data error, try again", __func__);
                    [self _viewNoDataError];
                    break;
                default:
                    // Error occur view
                    NSLog(@"[DEBUG] %s : Something went wrong", __func__);
                    [self _viewServerError];
                    break;
            }
            return;
        }
       if (albumInfos.count == 0) {
           self->isLastPage = YES;
       }
       [self.dataSource.albumInfos addObjectsFromArray:albumInfos];
       dispatch_async(dispatch_get_main_queue(), ^{
           [self.collectionView reloadData];
       });
    }];
}

- (void)_viewNetworkError {
    // Check if there is any image appear:
    if (self.dataSource.albumInfos.count > 0) {
        // Display toast only
        [self _displayNetworkErrorToast];
    } else {
        [self _displayNetworkErrorView];
    }
}

- (void)_displayNetworkErrorView {
    dispatch_async(dispatch_get_main_queue(), ^{
        NetworkErrorViewController *networkErrorVC = [[NetworkErrorViewController alloc] init];
        self.networkErrorViewController = networkErrorVC;
//        self.networkErrorViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.networkErrorViewController.view.frame = CGRectMake(0,
                                                                self.statusBarHeight +
                                                                self.navigationController.navigationBar.frame.size.height,
                                                                self.view.frame.size.width,
                                                                self.view.safeAreaLayoutGuide.layoutFrame.size.height);
        self.networkErrorViewController.delegate = self;
        [self addChildViewController:self.networkErrorViewController];
        [self.view addSubview: self.networkErrorViewController.view];
        [self.networkErrorViewController didMoveToParentViewController:self];    });
}

- (void)_displayNetworkErrorToast {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = @"Network connection unavailable";
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        int duration = 1; // duration in seconds
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

- (void)_viewNoDataError {
    dispatch_async(dispatch_get_main_queue(), ^{
        NoDataErrorViewController *noDataErrorVC = [[NoDataErrorViewController alloc] init];
        self.noDataErrorViewController = noDataErrorVC;
        self.noDataErrorViewController.view.frame = CGRectMake(0,
                                                               self.statusBarHeight +
                                                               self.navigationController.navigationBar.frame.size.height,
                                                               self.view.frame.size.width,
                                                               self.view.safeAreaLayoutGuide.layoutFrame.size.height);
        self.noDataErrorViewController.delegate = self;
        [self addChildViewController:self.noDataErrorViewController];
        [self.view addSubview: self.noDataErrorViewController.view];
        [self.noDataErrorViewController didMoveToParentViewController:self];
    });
}

- (void)_viewServerError {
    dispatch_async(dispatch_get_main_queue(), ^{
        ServerErrorViewController *serverErrorVC = [[ServerErrorViewController alloc] init];
        self.serverErrorViewController = serverErrorVC;
        self.serverErrorViewController.view.frame = CGRectMake(0,
                                                               self.statusBarHeight +
                                                               self.navigationController.navigationBar.frame.size.height,
                                                               self.view.frame.size.width,
                                                               self.view.safeAreaLayoutGuide.layoutFrame.size.height);
        self.serverErrorViewController.delegate = self;
        [self addChildViewController:self.serverErrorViewController];
        [self.view addSubview: self.serverErrorViewController.view];
        [self.serverErrorViewController didMoveToParentViewController:self];
    });
}

- (void)_selectAlbumInfoAtIndexPath:(NSIndexPath *)indexPath {
    AlbumInfo *albumInfo = self.dataSource.albumInfos[indexPath.row];
    [self _selectAlbumInfo:albumInfo];
    // Change the color of the cell
    AlbumInfoCollectionViewCell *cell = (AlbumInfoCollectionViewCell *)[self.collectionView
                                                                        cellForItemAtIndexPath:indexPath];
    UIView *coloredView = [[UIView alloc] initWithFrame:cell.bounds];
    coloredView.backgroundColor = kAppleBlueAlpha;
    cell.selectedBackgroundView = coloredView;
}

- (void)_selectAlbumInfo:(AlbumInfo *)albumInfo {
    NSLog(@"[DEBUG] %s : albumID: %@, albumName: %@", __func__, albumInfo.albumID, albumInfo.albumName);
    self.selectedAlbumInfo = albumInfo;
    [self _toggleSaveButton];
}

- (void)_deselectAlbumInfoAtIndexPath:(NSIndexPath *)indexPath {
    AlbumInfo *albumInfo = self.dataSource.albumInfos[indexPath.row];
    if (albumInfo == self.selectedAlbumInfo) {
        self.selectedAlbumInfo = nil;
        [self _toggleSaveButton];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.dataSource.albumInfos.count - numOfPhotosBeforeNewFetch && !isLastPage) {
        currentPage += 1;
        NSLog(@"[DEBUG] %s : API called!", __func__);
        [self _getAlbumInfosForPage:currentPage];
    }
}

#pragma mark - NetworkErrorViewDelegate
- (void)onRetryForNetworkErrorClicked {
    [self.networkErrorViewController willMoveToParentViewController:nil];
    [self.networkErrorViewController.view removeFromSuperview];
    [self.networkErrorViewController removeFromParentViewController];
    self.networkErrorViewController = nil;
    currentPage = 1;
    [self _getAlbumInfosForPage:currentPage];
}

#pragma mark - ServerErrorViewDelegate
- (void)onRetryForServerErrorClicked {
    [self.serverErrorViewController willMoveToParentViewController:nil];
    [self.serverErrorViewController.view removeFromSuperview];
    [self.serverErrorViewController removeFromParentViewController];
    self.serverErrorViewController = nil;
    currentPage = 1;
    [self _getAlbumInfosForPage:currentPage];
}

#pragma mark - NoDataErrorViewDelegate
- (void)onRetryForNoDataErrorClicked {
    [self.noDataErrorViewController willMoveToParentViewController:nil];
    [self.noDataErrorViewController.view removeFromSuperview];
    [self.noDataErrorViewController removeFromParentViewController];
    self.noDataErrorViewController = nil;
    currentPage = 1;
    [self _getAlbumInfosForPage:currentPage];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self _selectAlbumInfoAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self _deselectAlbumInfoAtIndexPath:indexPath];
}

#pragma mark - Custom Accessors

- (FixedFlowLayout *)fixedFlowLayout {
    if (_fixedFlowLayout) return _fixedFlowLayout;
    
    _fixedFlowLayout = [[FixedFlowLayout alloc] init];
    _fixedFlowLayout.sectionInset = UIEdgeInsetsMake(kMargin, kMargin, kMargin, kMargin);

    return _fixedFlowLayout;
}

- (UICollectionView *)collectionView {
    if (_collectionView) return _collectionView;
    
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                         collectionViewLayout:self.fixedFlowLayout];
    
    [_collectionView registerClass:[AlbumInfoCollectionViewCell class]
        forCellWithReuseIdentifier:AlbumInfoCollectionViewCell.reuseIdentifier];
    
    return _collectionView;
}

- (AlbumInfoDataSource *)dataSource {
    if (_dataSource) return _dataSource;
    
    _dataSource = [[AlbumInfoDataSource alloc] init];
    return _dataSource;
}

- (AlbumInfoManager *)albumInfoManager {
    if (_albumInfoManager) return _albumInfoManager;
    
    _albumInfoManager = [[AlbumInfoManager alloc] init];
    return _albumInfoManager;
}

- (CGFloat)statusBarHeight {
    UIWindowScene * scene = nil;
    for (UIWindowScene* wScene in [UIApplication sharedApplication].connectedScenes){
        if (wScene.activationState == UISceneActivationStateForegroundActive){
            scene = wScene;
            break;
        }
    }
    CGFloat statusBarHeight = scene.statusBarManager.statusBarFrame.size.height;
    return statusBarHeight;
}
@end
