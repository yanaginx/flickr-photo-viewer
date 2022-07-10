//
//  AlbumDetailViewController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 04/07/2022.
//

#import "AlbumDetailViewController.h"

#import "../../../../Common/Layouts/FixedLayout/FixedFlowLayout.h"
#import "../../../../Common/Constants/Constants.h"
#import "../../../../Models/AlbumInfo.h"

#import "../Views/AlbumDetailCollectionViewCell.h"
#import "DataSource/AlbumDetailDataSource.h"
#import "../Handlers/AlbumDetailPhotoManager.h"

#import "../../../Error/NetworkErrorViewController.h"
#import "../../../Error/ServerErrorViewController.h"
#import "../../../Error/NoDataErrorViewController.h"


@interface AlbumDetailViewController () <UICollectionViewDelegate,
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
@property (nonatomic, strong) AlbumDetailDataSource *dataSource;
@property (nonatomic, strong) AlbumDetailPhotoManager *albumDetailPhotoManager;

@end

@implementation AlbumDetailViewController

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
    [self setupCollectionView];
    [self setupTitleView];
    
    if (currentPage != 1) currentPage = 1;
    [self getAlbumDetailForAlbumID:self.albumInfo.albumID
                           pageNum:1];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews {
    self.collectionView.frame = CGRectMake(self.view.bounds.origin.x,
                                           self.view.bounds.origin.y,
                                           self.view.bounds.size.width,
                                           self.view.bounds.size.height);
    self.fixedFlowLayout.itemSize = CGSizeMake(self.collectionView.bounds.size.width / 2 - _fixedFlowLayout.minimumLineSpacing,
                                               self.collectionView.bounds.size.width / 2 - _fixedFlowLayout.minimumLineSpacing);
}


#pragma mark - Operations
- (void)setupCollectionView {
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.prefetchDataSource = self.dataSource;
    self.collectionView.delegate = self;
}

- (void)setupTitleView {
    UIImageView *albumCoverImageView = [[UIImageView alloc] init];
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.albumInfo.albumImageURL];
        if (imageData) {
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            dispatch_queue_main_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                albumCoverImageView.image = image;
            });
        }
    });
//    self.navigationItem.titleView = albumCoverImageView;
    self.navigationItem.title = self.albumInfo.albumName;
    self.navigationController.navigationBar.prefersLargeTitles = YES;
}

#pragma mark - Private methods
- (void)getAlbumDetailForAlbumID:(NSString *)albumID
                         pageNum:(NSInteger)pageNum {
    [self.albumDetailPhotoManager getAlbumDetailPhotosForAlbumID:albumID
                                                           page:pageNum
                                              completionHandler:^(NSMutableArray<Photo *> * _Nullable photos,
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
       if (photos.count == 0) {
           self->isLastPage = YES;
       }
       [self.dataSource.photos addObjectsFromArray:photos];
       dispatch_async(dispatch_get_main_queue(), ^{
           [self.collectionView reloadData];
       });
    }];
}

- (void)viewNetworkError {
    // Check if there is any image appear:
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
//        [self.navigationController pushViewController:networkErrorVC animated:NO];
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
//        [self.navigationController pushViewController:noDataErrorVC animated:NO];
    });
}

- (void)viewServerError {
    dispatch_async(dispatch_get_main_queue(), ^{
        ServerErrorViewController *serverErrorVC = [[ServerErrorViewController alloc] init];
        serverErrorVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        serverErrorVC.view.frame = self.view.bounds;
        serverErrorVC.delegate = self;
//        [self.navigationController pushViewController:serverErrorVC animated:NO];
    });
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.dataSource.photos.count - numOfPhotosBeforeNewFetch && !isLastPage) {
        currentPage += 1;
        NSLog(@"[DEBUG] %s : API called!", __func__);
        [self getAlbumDetailForAlbumID:self.albumInfo.albumID
                               pageNum:currentPage];
    }
}

#pragma mark - NetworkErrorViewDelegate
- (void)onRetryForNetworkErrorClicked {
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self getAlbumDetailForAlbumID:self.albumInfo.albumID
                           pageNum:currentPage];
}

#pragma mark - ServerErrorViewDelegate
- (void)onRetryForServerErrorClicked {
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self getAlbumDetailForAlbumID:self.albumInfo.albumID
                           pageNum:currentPage];
}

#pragma mark - NoDataErrorViewDelegate
- (void)onRetryForNoDataErrorClicked {
    [self.navigationController popViewControllerAnimated:NO];
    currentPage = 1;
    [self getAlbumDetailForAlbumID:self.albumInfo.albumID
                           pageNum:currentPage];
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
    
    [_collectionView registerClass:[AlbumDetailCollectionViewCell class]
        forCellWithReuseIdentifier:AlbumDetailCollectionViewCell.reuseIdentifier];
    
    return _collectionView;
}

- (AlbumDetailDataSource *)dataSource {
    if (_dataSource) return _dataSource;
    
    _dataSource = [[AlbumDetailDataSource alloc] init];
    return _dataSource;
}

- (AlbumDetailPhotoManager *)albumDetailPhotoManager {
    if (_albumDetailPhotoManager) return _albumDetailPhotoManager;
    
    _albumDetailPhotoManager = [[AlbumDetailPhotoManager alloc] init];
    return _albumDetailPhotoManager;
}

@end

