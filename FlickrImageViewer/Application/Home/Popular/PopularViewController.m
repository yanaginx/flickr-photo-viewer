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
    NSInteger numOfPhotosBeforeNewFetch;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) DynamicCollectionViewLayout *dynamicLayout;
@property (nonatomic, strong) PopularPhotoDataSource *dataSource;
@property (nonatomic, strong) PopularPhotoManager *popularPhotoManager;
@property (nonatomic, strong) PopularPhotoViewModel *popularPhotoViewModel;

@end

@implementation PopularViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        currentPage = 1;
        numOfPhotosBeforeNewFetch = 5;
        isLastPage = NO;
        
        self.dynamicLayout = [[DynamicCollectionViewLayout alloc] init];
        self.popularPhotoManager = [[PopularPhotoManager alloc] init];
        self.popularPhotoViewModel = [[PopularPhotoViewModel alloc] initWithDynamicLayout:self.dynamicLayout
                                                                             photoManager:self.popularPhotoManager];
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                 collectionViewLayout:self.dynamicLayout];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.cyanColor;
    if (currentPage != 1) currentPage = 1;
    [self initialSetup];
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

- (void)initialSetup {
    [self setupCollectionView];
    [self setupDynamicLayout];
    [self setupViewModel];
}

- (void)setupViewModel {
    self.popularPhotoViewModel.photoFetcherdelegate = self;
}

- (void)setupCollectionView {
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.prefetchDataSource = self.dataSource;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[PopularPhotoCollectionViewCell class]
            forCellWithReuseIdentifier:PopularPhotoCollectionViewCell.reuseIdentifier];
    [self.view addSubview:self.collectionView];
}

- (void)setupDynamicLayout {
    self.dynamicLayout.dataSource = self.popularPhotoViewModel;
    self.dynamicLayout.fixedHeight = kIsFixedHeight;
    self.dynamicLayout.rowMaximumHeight = kMaxRowHeight;
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
    if (indexPath.row == self.popularPhotoViewModel.numberOfItems - numOfPhotosBeforeNewFetch &&
        !isLastPage) {
        currentPage += 1;
        NSLog(@"[DEBUG] %s : API called!", __func__);
        [self.popularPhotoViewModel getPhotosForPage:currentPage];
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
                [self viewNetworkError];
                break;
            case kNoDataError:
                // No data error view
                NSLog(@"[DEBUG] %s : No data error, try again", __func__);
                [self viewNoDataError];
                break;
            default:
                // Error occur view
                NSLog(@"[DEBUG] %s : Something went wrong", __func__);
                [self viewServerError];
                break;
        }
        return;
    }
    self->isLastPage = isLastPage;
    dispatch_async(dispatch_get_main_queue(), ^{
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
- (void)viewNetworkError {
    // Check if there is any image appear:
    if (self.popularPhotoViewModel.numberOfItems > 0) {
        // Display toast only
        [self displayNetworkErrorToast];
    } else {
        [self displayNetworkErrorView];
    }
}

- (void)displayNetworkErrorView {
    dispatch_async(dispatch_get_main_queue(), ^{
        NetworkErrorViewController *networkErrorVC = [[NetworkErrorViewController alloc] init];
        networkErrorVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        networkErrorVC.view.frame = self.view.bounds;
        networkErrorVC.delegate = self;
        [self.navigationController pushViewController:networkErrorVC animated:NO];
    });
}

- (void)displayNetworkErrorToast {
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

- (void)viewNoDataError {
    dispatch_async(dispatch_get_main_queue(), ^{
        NoDataErrorViewController *noDataErrorVC = [[NoDataErrorViewController alloc] init];
        noDataErrorVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        noDataErrorVC.view.frame = self.navigationController.view.bounds;
        noDataErrorVC.delegate = self;
        [self.navigationController pushViewController:noDataErrorVC animated:NO];
    });
}

- (void)viewServerError {
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
