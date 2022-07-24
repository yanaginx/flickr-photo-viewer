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


#define kSlowVelocityNum 5
#define kFastVelocityNum 3

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
    BOOL isErrorPageDisplaying;
    CGPoint lastOffset;
    NSTimeInterval lastOffsetCapture;
    BOOL isScrollingFast;
    BOOL isAPICalling;
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
        numOfPhotosBeforeNewFetch = kSlowVelocityNum;
        isLastPage = NO;
        isRefreshing = NO;
        isAPICalling = NO;
        
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
    isAPICalling = YES;
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

- (void)scrollToTop {
    [self.collectionView setContentOffset:CGPointMake(0, -self.collectionView.safeAreaInsets.top)
                                 animated:YES];
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
        if (isErrorPageDisplaying) {
            isErrorPageDisplaying = NO;
            [self.navigationController popViewControllerAnimated:NO];
        }
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
        if (indexPath.row >= self.popularPhotoViewModel.numberOfItems - numOfPhotosBeforeNewFetch &&
            !isLastPage) {
            NSInteger expectedCurrentPage = ceil((float)self.popularPhotoViewModel.numberOfItems/kResultsPerPage.integerValue);
            if (currentPage <= expectedCurrentPage) currentPage = expectedCurrentPage;
            currentPage += 1;
            [self.popularPhotoViewModel getPhotosForPage:currentPage];
        }
    }
}

#pragma mark - PopularPhotoViewModelDelegate
- (void)onFinishGettingPhotosWithErrorCode:(NSNumber *)errorCodeNumber
                            lastPageStatus:(NSNumber *)isLastPageNumber {
    isAPICalling = NO;
    NSInteger errorCode = [errorCodeNumber integerValue];
    BOOL isLastPage = [isLastPageNumber boolValue];
   
    if (errorCode != 0) {
        switch (errorCode) {
            case kNetworkError:
                // Network error view
                NSLog(@"[DEBUG] %s : No internet connection", __func__);
                if (self->isRefreshing) {
                    self->isRefreshing = NO;
                    [self.refreshControl endRefreshing];
                }
                self->isErrorPageDisplaying = YES;
                [self _viewNetworkError];
                break;
            case kNoDataError:
                // No data error view
                NSLog(@"[DEBUG] %s : No data error, try again", __func__);
                if (self->isRefreshing) {
                    self->isRefreshing = NO;
                    [self.refreshControl endRefreshing];
                }
                self->isErrorPageDisplaying = YES;
                [self _viewNoDataError];
                break;
            default:
                // Error occur view
                NSLog(@"[DEBUG] %s : Something went wrong", __func__);
                if (self->isRefreshing) {
                    self->isRefreshing = NO;
                    [self.refreshControl endRefreshing];
                }
                self->isErrorPageDisplaying = YES;
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
    self->isErrorPageDisplaying = NO;
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self.popularPhotoViewModel removeAllPhotos];
    [self.popularPhotoViewModel getPhotosForPage:currentPage];
}

#pragma mark - ServerErrorViewDelegate
- (void)onRetryForServerErrorClicked {
    self->isErrorPageDisplaying = NO;
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self.popularPhotoViewModel removeAllPhotos];
    [self.popularPhotoViewModel getPhotosForPage:currentPage];
}

#pragma mark - NoDataErrorViewDelegate
- (void)onRetryForNoDataErrorClicked {
    self->isErrorPageDisplaying = NO;
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self.popularPhotoViewModel removeAllPhotos];
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

//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//    float scrollViewHeight = scrollView.frame.size.height;
//    float scrollContentSizeHeight = scrollView.contentSize.height;
//    float scrollOffset = scrollView.contentOffset.y;
//
//    if ((scrollOffset + scrollViewHeight >= scrollContentSizeHeight * 0.6 &&
//        scrollOffset + scrollViewHeight <= scrollContentSizeHeight * 0.7) ||
//        scrollOffset + scrollViewHeight >= scrollContentSizeHeight) {
//        // Load more cell here
//        //This condition will be true when scrollview will reach to bottom
//        if (self.popularPhotoManager.isConnected) {
//            if (!isAPICalling && !isLastPage) {
//                NSInteger expectedCurrentPage = ceil((float)self.popularPhotoViewModel.numberOfItems/kResultsPerPage.integerValue);
//                if (currentPage <= expectedCurrentPage) currentPage = expectedCurrentPage;
//                currentPage += 1;
//                [self.popularPhotoViewModel getPhotosForPage:currentPage];
//            }
//        }
//    }
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint currentOffset = scrollView.contentOffset;
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];

    NSTimeInterval timeDiff = currentTime - lastOffsetCapture;
    if(timeDiff > 0.1) {
        CGFloat distance = currentOffset.y - lastOffset.y;
        //The multiply by 10, / 1000 isn't really necessary.......
        CGFloat scrollSpeedNotAbs = (distance * 10) / 1000; //in pixels per millisecond

        CGFloat scrollSpeed = fabs(scrollSpeedNotAbs);
        if (scrollSpeed > 0.5) {
            isScrollingFast = YES;
            float scrollViewHeight = scrollView.frame.size.height;
            float scrollContentSizeHeight = scrollView.contentSize.height;
            float scrollOffset = scrollView.contentOffset.y;

//            NSLog(@"FAST VH: %f \n ContentH : %f\n scrollOffset : %f", scrollViewHeight, scrollContentSizeHeight, scrollOffset);
            if ((scrollOffset + scrollViewHeight >= scrollContentSizeHeight * 0.89 &&
                scrollOffset + scrollViewHeight <= scrollContentSizeHeight * 0.9) ||
                (scrollOffset + scrollViewHeight >= scrollContentSizeHeight * 0.79 &&
                 scrollOffset + scrollViewHeight <= scrollContentSizeHeight * 0.8) ||
                scrollOffset + scrollViewHeight >= scrollContentSizeHeight) {
                // Load more cell here
                //This condition will be true when scrollview will reach to bottom
                if (self.popularPhotoManager.isConnected) {
                    if (!isAPICalling && !isLastPage) {
                        NSInteger expectedCurrentPage = ceil((float)self.popularPhotoViewModel.numberOfItems/kResultsPerPage.integerValue);
                        if (currentPage <= expectedCurrentPage) currentPage = expectedCurrentPage;
                        currentPage += 1;
                        [self.popularPhotoViewModel getPhotosForPage:currentPage];
                    }
                }
            }
            numOfPhotosBeforeNewFetch = kFastVelocityNum;
        } else {
            isScrollingFast = NO;
//            float scrollViewHeight = scrollView.frame.size.height;
//            float scrollContentSizeHeight = scrollView.contentSize.height;
//            float scrollOffset = scrollView.contentOffset.y;
//
//            NSLog(@" VH: %f \n ContentH : %f\n scrollOffset : %f", scrollViewHeight, scrollContentSizeHeight, scrollOffset);
//            if ((scrollOffset + scrollViewHeight >= scrollContentSizeHeight * 0.75 &&
//                scrollOffset + scrollViewHeight <= scrollContentSizeHeight * 0.80) ||
//                scrollOffset + scrollViewHeight >= scrollContentSizeHeight) {
//                // Load more cell here
//                //This condition will be true when scrollview will reach to bottom
//                if (!isAPICalling && !isLastPage) {
//                    if (self.popularPhotoManager.isConnected) {
//                        NSInteger expectedCurrentPage = ceil((float)self.popularPhotoViewModel.numberOfItems/kResultsPerPage.integerValue);
//                        if (currentPage <= expectedCurrentPage) currentPage = expectedCurrentPage;
//                        currentPage += 1;
//                        [self.popularPhotoViewModel getPhotosForPage:currentPage];
//                    }
//
//                }
//            }
            numOfPhotosBeforeNewFetch = kSlowVelocityNum;
        }

        lastOffset = currentOffset;
        lastOffsetCapture = currentTime;
    }

}

#pragma mark - Custom Accessors
- (PopularPhotoDataSource *)dataSource {
    if (_dataSource) return _dataSource;
    _dataSource = [[PopularPhotoDataSource alloc] initWithViewModel:self.popularPhotoViewModel];
    return _dataSource;
}

@end
