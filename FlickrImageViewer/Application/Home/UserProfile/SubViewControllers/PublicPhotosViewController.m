//
//  PublicPhotosViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 30/06/2022.
//

#import "PublicPhotosViewController.h"

#import "../Handlers/PublicPhotoManager.h"

#import "../../../../Common/Utilities/AsyncFetcher/AsyncImageFetcher.h"

#import "../../../../Common/Layouts/DynamicLayout/DynamicCollectionViewLayout.h"
#import "../../../../Common/Layouts/FixedLayout/FixedFlowLayout.h"
#import "../../../../Common/Extensions/UISegmentedControl+Additions.h"
#import "../../../../Common/Constants/Constants.h"
#import "../../../../Models/Photo.h"
#import "../UserProfileConstants.h"

#import "../../../Error/NetworkErrorViewController.h"
#import "../../../Error/ServerErrorViewController.h"
#import "../../../Error/NoDataErrorViewController.h"

#import "DataSource/PublicPhotoDataSource.h"

#import "../Views/PublicPhotoCollectionViewCell.h"


@interface PublicPhotosViewController () <DynamicCollectionViewLayoutDataSource,
                                          UICollectionViewDelegate,
                                          UICollectionViewDelegateFlowLayout,
                                          NetworkErrorViewDelegate,
                                          ServerErrorViewDelegate,
                                          NoDataErrorViewDelegate> {
    NSInteger currentPage;
    NSInteger numOfPhotosBeforeNewFetch;
    BOOL isLastPage;
    BOOL isRefreshing;
    NSInteger dynamicLayoutIdx;
    NSInteger fixedLayoutIdx;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) DynamicCollectionViewLayout *dynamicLayout;
@property (nonatomic, strong) FixedFlowLayout *fixedFlowLayout;
@property (nonatomic, strong) PublicPhotoDataSource *dataSource;
@property (nonatomic, strong) PublicPhotoManager *publicPhotoManager;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UISegmentedControl *layoutSegmentedControl;

@end


@implementation PublicPhotosViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        currentPage = 1;
        numOfPhotosBeforeNewFetch = 1;
        isLastPage = NO;
        isRefreshing = NO;
        dynamicLayoutIdx = 0;
        fixedLayoutIdx = 1;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"[DEBUG] %s did run!", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (currentPage != 1) currentPage = 1;

    [self _setupViews];
    [self _getPhotoURLsForPage:currentPage];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillLayoutSubviews {
    self.collectionView.frame = CGRectMake(self.view.bounds.origin.x,
                                           self.view.bounds.origin.y + kLayoutSegmentedControlHeight,
                                           self.view.bounds.size.width,
                                           self.view.bounds.size.height - kLayoutSegmentedControlHeight);
}
//    self.layoutSegmentedControl.frame = CGRectMake(self.view.bounds.origin.x,
//                                                   self.view.bounds.origin.y,
//                                                   kLayoutSegmentedControlHeight * 2,
//                                                   kLayoutSegmentedControlHeight);
//}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDarkContent;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - Public methods
- (void)getPhotosForFirstPage {
    currentPage = 1;
    if (isRefreshing) {
        // Call the delegate to cancel the refreshing
        [self.delegate cancelRefreshingAfterFetchingPublicPhotos];
    }
    isRefreshing = YES;
    if (self.publicPhotoManager.isConnected)  {
        [self.dataSource.photos removeAllObjects];
        [self.dynamicLayout clearCache];
    }
    [self _getPhotoURLsForPage:currentPage];
}

#pragma mark - Private methods
- (void)_getPhotoURLsForPage:(NSInteger)pageNum {
    if (!self.publicPhotoManager.isConnected &&
        self.dataSource.photos.count > 0) {
        isRefreshing = NO;
        [self.delegate cancelRefreshingAfterFetchingPublicPhotos];
        return;
    }
    [self.publicPhotoManager getPublicPhotoURLsWithPage:pageNum
                                      completionHandler:^(NSMutableArray<Photo *> * _Nullable photosFetched,
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
        
        if (photosFetched.count == 0) {
            self->isLastPage = YES;
        }
        [self.dataSource.photos addObjectsFromArray:photosFetched];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Delegate calling to stop refreshing when finish fetching data
            if (self->isRefreshing) {
                self->isRefreshing = NO;
                [self.delegate cancelRefreshingAfterFetchingPublicPhotos];
            }
            [self.collectionView reloadData];
        });
    }];
}

#pragma mark - DynamicCollectionViewLayoutDataSource
- (CGSize)dynamicCollectionViewLayout:(DynamicCollectionViewLayout *)layout
         originalImageSizeAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataSource.photos.count) {
        Photo *photo = self.dataSource.photos[indexPath.row];
        return photo.imageSize;
    }
    return CGSizeMake(0.1, 0.1);
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;
    size = (self.layoutSegmentedControl.selectedSegmentIndex == dynamicLayoutIdx) ?
            [self.dynamicLayout sizeForPhotoAtIndexPath:indexPath] :
            self.fixedFlowLayout.itemSize;
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == self.photos.count - numOfPhotosBeforeNewFetch && !isLastPage) {
//    NSInteger indexForFetching = self.dataSource.photos.count == kResultsPerPage.integerValue ?
//    self.dataSource.photos.count - numOfPhotosBeforeNewFetch :
//    kResultsPerPage.integerValue - numOfPhotosBeforeNewFetch;
    if (indexPath.row == self.dataSource.photos.count - 1 && !isLastPage) {
        currentPage += 1;
        NSLog(@"[DEBUG] %s : API called!", __func__);
        [self _getPhotoURLsForPage:currentPage];
    }
}

#pragma mark - NetworkErrorViewDelegate
- (void)onRetryForNetworkErrorClicked {
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self _getPhotoURLsForPage:currentPage];
}

#pragma mark - ServerErrorViewDelegate
- (void)onRetryForServerErrorClicked {
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self _getPhotoURLsForPage:currentPage];
}

#pragma mark - NoDataErrorViewDelegate
- (void)onRetryForNoDataErrorClicked {
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self _getPhotoURLsForPage:currentPage];
}

#pragma mark - Private methods
- (void)_viewNetworkError {
    // Check if there is any image appear:
    if (self.dataSource.photos.count > 0) {
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

- (void)_setupViews {
    [self _setupCollectionView];
    [self _setupLayoutSegmentedControl];
}

- (void)_setupLayoutSegmentedControl {
    [self.view addSubview:self.layoutSegmentedControl];
    [self.layoutSegmentedControl removeAllSegments];
    UIImage *dynamicLayoutIcon = [[UIImage imageNamed:@"ic_dynamic_layout"]
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    UIImage *dynamicLayoutIcon = [UIImage imageNamed:@"ic_dynamic_layout_outlined"];
//    UIImage *fixedLayoutIcon = [UIImage imageNamed:@"ic_fixed_layout_outlined"];
    UIImage *fixedLayoutIcon = [[UIImage imageNamed:@"ic_fixed_layout_outlined"]
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];


    [self.layoutSegmentedControl insertSegmentWithImage:dynamicLayoutIcon
                                                atIndex:dynamicLayoutIdx
                                               animated:NO];
    [self.layoutSegmentedControl insertSegmentWithImage:fixedLayoutIcon
                                                atIndex:fixedLayoutIdx
                                               animated:NO];
    [self.layoutSegmentedControl addTarget:self
                                    action:@selector(_onSegmentedSelectionChanged:)
                          forControlEvents:UIControlEventValueChanged];
    self.layoutSegmentedControl.selectedSegmentIndex = dynamicLayoutIdx;
    self.layoutSegmentedControl.frame = CGRectMake(self.view.bounds.origin.x,
                                                   self.view.bounds.origin.y,
                                                   self.view.bounds.size.width / 3,
                                                   kLayoutSegmentedControlHeight);
    [self.layoutSegmentedControl layoutIfNeeded];
    [self.layoutSegmentedControl removeBorder];
}

- (void)_setupCollectionView {
    [self.view addSubview:self.collectionView];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.dataSource = self.dataSource;
//    self.collectionView.prefetchDataSource = self.dataSource;
    self.collectionView.delegate = self;
}

- (void)_onSegmentedSelectionChanged:(UISegmentedControl *)segment {
    [self _updateIcon];
    [self _updateLayout];
}

- (void)_updateIcon {
    if (self.layoutSegmentedControl.selectedSegmentIndex == dynamicLayoutIdx) {
        [self.layoutSegmentedControl setImage:[UIImage imageNamed:@"ic_dynamic_layout"]
                            forSegmentAtIndex:dynamicLayoutIdx];
        [self.layoutSegmentedControl setImage:[UIImage imageNamed:@"ic_fixed_layout_outlined"]
                            forSegmentAtIndex:fixedLayoutIdx];
    }
    if (self.layoutSegmentedControl.selectedSegmentIndex == fixedLayoutIdx) {
        [self.layoutSegmentedControl setImage:[UIImage imageNamed:@"ic_fixed_layout"]
                            forSegmentAtIndex:fixedLayoutIdx];
        [self.layoutSegmentedControl setImage:[UIImage imageNamed:@"ic_dynamic_layout_outlined"]
                            forSegmentAtIndex:dynamicLayoutIdx];
    }
}

- (void)_updateLayout {
    if (self.layoutSegmentedControl.selectedSegmentIndex == dynamicLayoutIdx) {
        [self _switchToDynamicLayout];
    } else {
        [self _switchToFixedLayout];
    }
}

- (void)_switchToDynamicLayout {
    [self.collectionView setCollectionViewLayout:self.dynamicLayout animated:YES];
//    [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
    [self.collectionView reloadData];
//    if (self.dataSource.photos.count > 0) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
//        [self.collectionView scrollToItemAtIndexPath:indexPath
//                                    atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
//    }
}

- (void)_switchToFixedLayout {
    [self.collectionView setCollectionViewLayout:self.fixedFlowLayout animated:YES];
//    [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
    [self.collectionView reloadData];
//    if (self.dataSource.photos.count > 0) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
//        [self.collectionView scrollToItemAtIndexPath:indexPath
//                                    atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
//    }
}

#pragma mark - Custom Accessors
- (PublicPhotoDataSource *)dataSource {
    if (_dataSource) return _dataSource;
    _dataSource = [[PublicPhotoDataSource alloc] init];
    return _dataSource;
}

- (DynamicCollectionViewLayout *)dynamicLayout {
    if (_dynamicLayout) return _dynamicLayout;

    _dynamicLayout = [[DynamicCollectionViewLayout alloc] init];
    _dynamicLayout.dataSource = self;
    _dynamicLayout.fixedHeight = kIsFixedHeight;
    _dynamicLayout.rowMaximumHeight = kMaxRowHeight;
    return _dynamicLayout;
}

- (FixedFlowLayout *)fixedFlowLayout {
    if (_fixedFlowLayout) return _fixedFlowLayout;
    
    _fixedFlowLayout = [[FixedFlowLayout alloc] init];
    _fixedFlowLayout.itemSize = CGSizeMake(self.collectionView.bounds.size.width, kMaxRowHeight);
    return _fixedFlowLayout;
}

- (UICollectionView *)collectionView {
    if (_collectionView) return _collectionView;
    
   
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                         collectionViewLayout:self.dynamicLayout];

    [_collectionView registerClass:[PublicPhotoCollectionViewCell class]
        forCellWithReuseIdentifier:PublicPhotoCollectionViewCell.reuseIdentifier];
    
    return _collectionView;
}

- (UISegmentedControl *)layoutSegmentedControl {
    if (_layoutSegmentedControl) return _layoutSegmentedControl;
    _layoutSegmentedControl = [[UISegmentedControl alloc] init];
    return _layoutSegmentedControl;
}

- (PublicPhotoManager *)publicPhotoManager {
    if (_publicPhotoManager) return _publicPhotoManager;
    
    _publicPhotoManager = [[PublicPhotoManager alloc] init];
    return _publicPhotoManager;
}

- (UIRefreshControl *)refreshControl {
    if (_refreshControl) return _refreshControl;
    _refreshControl = [[UIRefreshControl alloc] init];
    return _refreshControl;
}

@end
