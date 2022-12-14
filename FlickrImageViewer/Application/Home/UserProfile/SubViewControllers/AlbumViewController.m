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
    BOOL isRefreshing;
    BOOL isErrorPageDisplaying;
    NSInteger numOfPhotosBeforeNewFetch;
    NSUInteger totalNumberOfAlbumInfos;
    NSInteger numberOfPages;
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
        isRefreshing = NO;
        isErrorPageDisplaying = NO;
        numOfPhotosBeforeNewFetch = 2;
        numberOfPages = LONG_MAX;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"[DEBUG] %s did run!", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
    
    if (currentPage != 1) currentPage = 1;
    [self _getAlbumInfosForPage:currentPage];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews {
    self.collectionView.frame = CGRectMake(self.view.bounds.origin.x,
                                           self.view.bounds.origin.y,
                                           self.view.bounds.size.width,
                                           self.view.bounds.size.height);
//    self.fixedFlowLayout.itemSize = CGSizeMake(self.collectionView.bounds.size.width - _fixedFlowLayout.minimumLineSpacing * 2, kCellHeight);
    self.fixedFlowLayout.itemSize = CGSizeMake(self.collectionView.bounds.size.width -
                                               _fixedFlowLayout.minimumLineSpacing * 2,
                                               kMaxRowHeight - _fixedFlowLayout.minimumLineSpacing * 2);

}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    if (isRefreshing) {
        [self.delegate cancelRefreshingAfterFetchingAlbums];
    }
}


#pragma mark - Public methods
- (void)getAlbumsForFirstPage {
    currentPage = 1;
    if (isRefreshing) {
        // Call the delegate to cancel the refreshing
        isRefreshing = NO;
        [self.delegate cancelRefreshingAfterFetchingAlbums];
    }
    isRefreshing = YES;
    if (self.albumInfoManager.isConnected) {
        [self.dataSource.albumInfos removeAllObjects];
        [self.albumInfoManager clearLocalAlbumInfos];
    }
    if (isErrorPageDisplaying) {
        isErrorPageDisplaying = NO;
        [self.navigationController popViewControllerAnimated:NO];
    }
    [self _getAlbumInfosForPage:currentPage];
}

#pragma mark - Operations
- (void)_setupViews {
    [self _setupCollectionView];
}

- (void)_setupCollectionView {
    [self.view addSubview:self.collectionView];
//    self.collectionView.backgroundColor = UIColor.lightGrayColor;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.delegate = self;
}

- (void)_getAlbumInfosForPage:(NSInteger)pageNum {
    if (!self.albumInfoManager.isConnected &&
        self.dataSource.albumInfos.count > 0) {
        isRefreshing = NO;
        [self.delegate cancelRefreshingAfterFetchingAlbums];
        return;
    }
   [self.albumInfoManager getUserAlbumInfosWithPage:pageNum
                                  completionHandler:^(NSMutableArray<AlbumInfo *> * _Nullable albumInfos,
                                                      NSError * _Nullable error,
                                                      NSNumber *totalAlbumInfosNumber) {
        
        NSLog(@"[DEBUG] %s : API called!", __func__);
        if (error) {
            switch (error.code) {
                case kNetworkError:
                    // Network error view
                    NSLog(@"[DEBUG] %s : No internet connection", __func__);
                    if (self->isRefreshing) {
                        self->isRefreshing = NO;
                        [self.delegate cancelRefreshingAfterFetchingAlbums];
                    }
                    self->isErrorPageDisplaying = YES;
                    [self _viewNetworkError];
                    break;
                case kNoDataError:
                    // No data error view
                    NSLog(@"[DEBUG] %s : No data error, try again", __func__);
                    if (self->isRefreshing) {
                        self->isRefreshing = NO;
                        [self.delegate cancelRefreshingAfterFetchingAlbums];
                    }
                    self->isErrorPageDisplaying = YES;
                    [self _viewNoDataError];
                    break;
                default:
                    // Error occur view
                    NSLog(@"[DEBUG] %s : Something went wrong", __func__);
                    if (self->isRefreshing) {
                        self->isRefreshing = NO;
                        [self.delegate cancelRefreshingAfterFetchingAlbums];
                    }
                    self->isErrorPageDisplaying = YES;
                    [self _viewServerError];
                    break;
            }
            return;
        }
       if (albumInfos.count == 0) {
           self->isLastPage = YES;
       }
       
       self->totalNumberOfAlbumInfos = (totalAlbumInfosNumber != nil)? totalAlbumInfosNumber.integerValue : 0;
       self->numberOfPages = self->totalNumberOfAlbumInfos == 0 ?
                             self->numberOfPages :
                             ceil((float)self->totalNumberOfAlbumInfos / kResultsPerPage.floatValue);

       [self.dataSource.albumInfos addObjectsFromArray:albumInfos];
       dispatch_async(dispatch_get_main_queue(), ^{
           if (self->isRefreshing) {
               self->isRefreshing = NO;
               [self.delegate cancelRefreshingAfterFetchingAlbums];
           }
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
//    NSInteger indexForFetching = self.dataSource.albumInfos.count == kResultsPerPage.integerValue ?
//    self.dataSource.albumInfos.count - numOfPhotosBeforeNewFetch :
//    kResultsPerPage.integerValue - numOfPhotosBeforeNewFetch;
    if (indexPath.row == self.dataSource.albumInfos.count - numOfPhotosBeforeNewFetch &&
        (currentPage < numberOfPages || !isLastPage)) {
        NSInteger expectedCurrentPage = ceil((float)self.dataSource.albumInfos.count / kResultsPerPage.floatValue);
        if (currentPage <= expectedCurrentPage) currentPage = expectedCurrentPage;
        currentPage += 1;
//    if (indexPath.row == self.dataSource.albumInfos.count - 1 && !isLastPage) {
//        currentPage += 1;
//        NSLog(@"[DEBUG] %s : API called!", __func__);
        [self _getAlbumInfosForPage:currentPage];
    }
}

#pragma mark - NetworkErrorViewDelegate
- (void)onRetryForNetworkErrorClicked {
    self->isErrorPageDisplaying = NO;
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self.albumInfoManager clearLocalAlbumInfos];
    [self.dataSource.albumInfos removeAllObjects];
    [self _getAlbumInfosForPage:currentPage];
}

#pragma mark - ServerErrorViewDelegate
- (void)onRetryForServerErrorClicked {
    self->isErrorPageDisplaying = NO;
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self.albumInfoManager clearLocalAlbumInfos];
    [self.dataSource.albumInfos removeAllObjects];
    [self _getAlbumInfosForPage:currentPage];
}

#pragma mark - NoDataErrorViewDelegate
- (void)onRetryForNoDataErrorClicked {
    self->isErrorPageDisplaying = NO;
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self.albumInfoManager clearLocalAlbumInfos];
    [self.dataSource.albumInfos removeAllObjects];
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
