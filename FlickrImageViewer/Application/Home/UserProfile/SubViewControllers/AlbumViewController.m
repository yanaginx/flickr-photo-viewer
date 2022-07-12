//
//  AlbumViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 30/06/2022.
//

#import "AlbumViewController.h"

#import "../../../../Common/Layouts/FixedLayout/FixedFlowLayout.h"
#import "../../../../Common/Constants/Constants.h"

#import "../Views/AlbumInfoCollectionViewCell.h"
#import "DataSource/AlbumInfoDataSource.h"
#import "../Handlers/AlbumInfoManager.h"

#import "../../../Error/NetworkErrorViewController.h"
#import "../../../Error/ServerErrorViewController.h"
#import "../../../Error/NoDataErrorViewController.h"

#import "AlbumDetailViewController.h"

@interface AlbumViewController () <UICollectionViewDelegate,
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

@end

@implementation AlbumViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        currentPage = 1;
        isLastPage = NO;
        numOfPhotosBeforeNewFetch = 2;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    [self _setupCollectionView];
    
    if (currentPage != 1) currentPage = 1;
    [self _getAlbumInfosForPage:currentPage];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews {
    self.collectionView.frame = CGRectMake(self.view.bounds.origin.x,
                                           self.view.bounds.origin.y,
                                           self.view.bounds.size.width,
                                           self.view.bounds.size.height);
    self.fixedFlowLayout.itemSize = CGSizeMake(self.collectionView.bounds.size.width - _fixedFlowLayout.minimumLineSpacing * 2, kCellHeight);
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}


#pragma mark - Operations
- (void)_setupCollectionView {
    self.collectionView.backgroundColor = UIColor.lightGrayColor;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.delegate = self;
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
        networkErrorVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        networkErrorVC.view.frame = self.view.bounds;
        networkErrorVC.delegate = self;
        [self.navigationController pushViewController:networkErrorVC animated:NO];
    });
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
        noDataErrorVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        noDataErrorVC.view.frame = self.navigationController.view.bounds;
        noDataErrorVC.delegate = self;
        [self.navigationController pushViewController:noDataErrorVC animated:NO];
    });
}

- (void)_viewServerError {
    dispatch_async(dispatch_get_main_queue(), ^{
        ServerErrorViewController *serverErrorVC = [[ServerErrorViewController alloc] init];
        serverErrorVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        serverErrorVC.view.frame = self.view.bounds;
        serverErrorVC.delegate = self;
        [self.navigationController pushViewController:serverErrorVC animated:NO];
    
    });
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
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self _getAlbumInfosForPage:currentPage];
}

#pragma mark - ServerErrorViewDelegate
- (void)onRetryForServerErrorClicked {
    [self.navigationController popViewControllerAnimated:NO];
     currentPage = 1;
    [self _getAlbumInfosForPage:currentPage];
}

#pragma mark - NoDataErrorViewDelegate
- (void)onRetryForNoDataErrorClicked {
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self _getAlbumInfosForPage:currentPage];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumDetailViewController *albumDetailVC = [[AlbumDetailViewController alloc] init];
    AlbumInfo *currentAlbumInfo = self.dataSource.albumInfos[indexPath.row];
    albumDetailVC.albumInfo = currentAlbumInfo;
    [self.profileNavigationController pushViewController:albumDetailVC animated:YES];
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

@end
