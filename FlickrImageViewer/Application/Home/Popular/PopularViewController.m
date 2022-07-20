//
//  PopularViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import "PopularViewController.h"

#import "Handlers/PopularPhotoManager.h"

#import "../../../Common/Utilities/AsyncFetcher/AsyncImageFetcher.h"
#import "../../../Common/Layouts/DynamicLayout/DynamicCollectionViewLayout.h"
#import "../../../Common/Constants/Constants.h"
#import "../../../Models/Photo.h"

#import "../../Error/NetworkErrorViewController.h"
#import "../../Error/ServerErrorViewController.h"
#import "../../Error/NoDataErrorViewController.h"

#import "ViewModels/PopularPhotoViewModel.h"
#import "DataSource/PopularPhotoDataSource.h"

#import "Views/PopularPhotoCollectionViewCell.h"


@interface PopularViewController () <UICollectionViewDelegate,
                                     UICollectionViewDelegateFlowLayout,
                                     NetworkErrorViewDelegate,
                                     ServerErrorViewDelegate,
                                     NoDataErrorViewDelegate,
                                     PopularPhotoViewModelDelegate> {
    NSInteger currentPage;
    BOOL isLastPage;
    BOOL isRefreshing;
    NSInteger numOfPhotosBeforeNewFetch;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) DynamicCollectionViewLayout *dynamicLayout;
@property (nonatomic, strong) PopularPhotoDataSource *dataSource;
@property (nonatomic, strong) PopularPhotoManager *popularPhotoManager;
@property (nonatomic, strong) PopularPhotoViewModel *popularPhotoViewModel;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation PopularViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        currentPage = 1;
        numOfPhotosBeforeNewFetch = 1;
        isLastPage = NO;
        isRefreshing = NO;
        
        self.dynamicLayout = [[DynamicCollectionViewLayout alloc] init];
        self.popularPhotoManager = [[PopularPhotoManager alloc] init];
        self.popularPhotoViewModel = [[PopularPhotoViewModel alloc] initWithDynamicLayout:self.dynamicLayout
                                                                             photoManager:self.popularPhotoManager];
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                 collectionViewLayout:self.dynamicLayout];
        self.refreshControl = [[UIRefreshControl alloc] init];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"[DEBUG] %s: did run!", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.cyanColor;
    if (currentPage != 1) currentPage = 1;
    [self _initialSetup];
    [self.popularPhotoViewModel getPhotosForPage:currentPage];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillLayoutSubviews {
    self.collectionView.frame = self.view.bounds;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDarkContent;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}



#pragma mark - Operations

- (void)_initialSetup {
    [self _setupCollectionView];
    [self _setupDynamicLayout];
    [self _setupViewModel];
    [self _setupRefreshControl];
}

- (void)_setupViewModel {
    self.popularPhotoViewModel.photoFetcherdelegate = self;
}

- (void)_setupCollectionView {
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.dataSource = self.dataSource;
//    self.collectionView.prefetchDataSource = self.dataSource;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[PopularPhotoCollectionViewCell class]
            forCellWithReuseIdentifier:PopularPhotoCollectionViewCell.reuseIdentifier];
    [self.view addSubview:self.collectionView];
}

- (void)_setupDynamicLayout {
    self.dynamicLayout.dataSource = self.popularPhotoViewModel;
    self.dynamicLayout.fixedHeight = kIsFixedHeight;
    self.dynamicLayout.rowMaximumHeight = kMaxRowHeight;
}

- (void)_setupRefreshControl {
    currentPage = 1;
    [self.refreshControl addTarget:self
                            action:@selector(_getPhotosForCurrentPage)
                  forControlEvents:UIControlEventValueChanged];
    self.collectionView.refreshControl = self.refreshControl;
}

- (void)_getPhotosForCurrentPage {
    if (!isRefreshing) {
        isRefreshing = YES;
        currentPage = 1;
        [self.popularPhotoViewModel removeAllPhotos];
        [self.popularPhotoViewModel getPhotosForPage:currentPage];
    } else {
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;
    size = [self.popularPhotoViewModel itemSizeAtIndexPath:indexPath];
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    // Only call this when in online mode
    if (self.popularPhotoManager.isConnected) {
        if (indexPath.row == self.popularPhotoViewModel.numberOfItems - 1 &&
            !isLastPage) {
            NSInteger totalPages = self.popularPhotoViewModel.numberOfItems/kResultsPerPage.integerValue;
            NSInteger pagesToIncrease = totalPages - currentPage + 1;
            currentPage += pagesToIncrease;
            NSLog(@"[DEBUG] %s : API called!", __func__);
            [self.popularPhotoViewModel getPhotosForPage:currentPage];
        }
    }
}

#pragma mark - PopularPhotoViewModelDelegate
- (void)onFinishGettingPhotosWithErrorCode:(NSNumber *)errorCodeNumber
                            lastPageStatus:(NSNumber *)isLastPageNumber {
    NSInteger errorCode = [errorCodeNumber integerValue];
    BOOL isLastPage = [isLastPageNumber boolValue];
   
    if (errorCode != 0) {
        switch (errorCode) {
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
    self->isLastPage = isLastPage;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->isRefreshing) {
            self->isRefreshing = NO;
            [self.refreshControl endRefreshing];
        }
        [self.collectionView reloadData];
    });
}


#pragma mark - NetworkErrorViewDelegate

- (void)onRetryForNetworkErrorClicked {
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self.popularPhotoViewModel getPhotosForPage:currentPage];
}

#pragma mark - ServerErrorViewDelegate
- (void)onRetryForServerErrorClicked {
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self.popularPhotoViewModel getPhotosForPage:currentPage];
}

#pragma mark - NoDataErrorViewDelegate
- (void)onRetryForNoDataErrorClicked {
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self.popularPhotoViewModel getPhotosForPage:currentPage];

}

#pragma mark - Private methods
- (void)_viewNetworkError {
    // Check if there is any image appear:
    if (self.popularPhotoViewModel.numberOfItems > 0) {
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


#pragma mark - Custom Accessors
- (PopularPhotoDataSource *)dataSource {
    if (_dataSource) return _dataSource;
    _dataSource = [[PopularPhotoDataSource alloc] initWithViewModel:self.popularPhotoViewModel];
    return _dataSource;
}

@end
