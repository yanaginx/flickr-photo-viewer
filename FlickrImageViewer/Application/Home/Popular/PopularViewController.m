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

#import "DataSource/PopularPhotoDataSource.h"

#import "Views/PopularPhotoCollectionViewCell.h"


@interface PopularViewController () <DynamicCollectionViewLayoutDataSource,
                                     UICollectionViewDelegate,
                                     UICollectionViewDelegateFlowLayout,
                                     NetworkErrorViewDelegate,
                                     ServerErrorViewDelegate,
                                     NoDataErrorViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) DynamicCollectionViewLayout *dynamicLayout;
@property (nonatomic, strong) PopularPhotoDataSource *dataSource;

@end

@implementation PopularViewController

static NSInteger currentPage = 1;
static NSInteger numOfPhotosBeforeNewFetch = 5;
static BOOL isLastPage = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.cyanColor;
    [self.view addSubview:self.collectionView];
    if (currentPage != 1) currentPage = 1;
    [self setupCollectionView];
    [self getPhotoURLsForPage:currentPage];
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



#pragma mark - Private methods

- (void)getPhotoURLsForPage:(NSInteger)pageNum {
    [PopularPhotoManager.sharedPopularPhotoManager getPopularPhotoURLsWithPage:pageNum
                                                             completionHandler:^(NSMutableArray<Photo *> * _Nullable photosFetched,
                                                                                 NSError * _Nullable error) {
        NSLog(@"[DEBUG] %s : API called!", __func__);
        if (error) {
            switch (error.code) {
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
        
        if (photosFetched.count == 0) {
            isLastPage = YES;
        }
//        [self.photos addObjectsFromArray:photosFetched];
        [self.dataSource.photos addObjectsFromArray:photosFetched];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];
}

- (void)setupCollectionView {
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.prefetchDataSource = self.dataSource;
    self.collectionView.delegate = self;
}

#pragma mark - DynamicCollectionViewLayoutDataSource
- (CGSize)dynamicCollectionViewLayout:(DynamicCollectionViewLayout *)layout
         originalImageSizeAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row < self.photos.count) {
//        Photo *photo = self.photos[indexPath.row];
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
    size = [self.dynamicLayout sizeForPhotoAtIndexPath:indexPath];
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == self.photos.count - numOfPhotosBeforeNewFetch && !isLastPage) {
    if (indexPath.row == self.dataSource.photos.count - numOfPhotosBeforeNewFetch && !isLastPage) {
        currentPage += 1;
        NSLog(@"[DEBUG] %s : API called!", __func__);
        [self getPhotoURLsForPage:currentPage];
    }
}

#pragma mark - NetworkErrorViewDelegate

- (void)onRetryForNetworkErrorClicked {
    [self.navigationController popViewControllerAnimated:NO];
    [self getPhotoURLsForPage:1];
}

#pragma mark - ServerErrorViewDelegate
- (void)onRetryForServerErrorClicked {
    [self.navigationController popViewControllerAnimated:NO];
    [self getPhotoURLsForPage:1];
}

#pragma mark - NoDataErrorViewDelegate
- (void)onRetryForNoDataErrorClicked {
    [self.navigationController popViewControllerAnimated:NO];
    [self getPhotoURLsForPage:1];
}

#pragma mark - Private methods
- (void)viewNetworkError {
    // Check if there is any image appear:
//    if (self.photos.count > 0) {
    if (self.dataSource.photos.count > 0) {
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
- (DynamicCollectionViewLayout *)dynamicLayout {
    if (_dynamicLayout) return _dynamicLayout;

    _dynamicLayout = [[DynamicCollectionViewLayout alloc] init];
    _dynamicLayout.dataSource = self;
    _dynamicLayout.fixedHeight = NO;
    _dynamicLayout.rowMaximumHeight = 200;
    return _dynamicLayout;
}

- (UICollectionView *)collectionView {
    if (_collectionView) return _collectionView;
    
   
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                         collectionViewLayout:self.dynamicLayout];

    [_collectionView registerClass:[PopularPhotoCollectionViewCell class]
        forCellWithReuseIdentifier:PopularPhotoCollectionViewCell.reuseIdentifier];
    
    return _collectionView;
}

- (PopularPhotoDataSource *)dataSource {
    if (_dataSource) return _dataSource;
    _dataSource = [[PopularPhotoDataSource alloc] init];
    return _dataSource;
}


@end
