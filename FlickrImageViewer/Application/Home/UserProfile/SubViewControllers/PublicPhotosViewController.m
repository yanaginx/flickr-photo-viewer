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
#import "../../../../Common/Constants/Constants.h"
#import "../../../../Models/Photo.h"
#import "../UserProfileConstants.h"

#import "../../../Error/NetworkErrorViewController.h"
#import "../../../Error/ServerErrorViewController.h"
#import "../../../Error/NoDataErrorViewController.h"

#import "../Views/PublicPhotoCollectionViewCell.h"

@interface PublicPhotosViewController () <DynamicCollectionViewLayoutDataSource,
                                          UICollectionViewDelegate,
                                          UICollectionViewDelegateFlowLayout,
                                          UICollectionViewDataSource,
                                          UICollectionViewDataSourcePrefetching,
                                          NetworkErrorViewDelegate,
                                          ServerErrorViewDelegate,
                                          NoDataErrorViewDelegate>

@property (nonatomic, strong) NSMutableArray<NSURL *> *photoURLs;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) DynamicCollectionViewLayout *dynamicLayout;
@property (nonatomic, strong) FixedFlowLayout *fixedFlowLayout;
// cache for getting the image size
@property (nonatomic, strong) NSCache<NSUUID *, UIImage *> *photoImagesCache;
@property (nonatomic, strong) NSMutableArray<Photo *> *photos;
@property (nonatomic, strong) NSMutableDictionary<NSURL *, NSValue *> *originalImageSize;
@property (nonatomic, strong) AsyncImageFetcher *asyncFetcher;

@property (nonatomic, strong) UISegmentedControl *layoutSegmentedControl;


@end

@implementation PublicPhotosViewController

static NSInteger currentPage = 1;
static NSInteger numOfPhotosBeforeNewFetch = 5;
static BOOL isLastPage = NO;
static NSInteger dynamicLayoutIdx = 0;
static NSInteger fixedLayoutIdx = 1;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.view.backgroundColor = UIColor.cyanColor;
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.layoutSegmentedControl];
    [self setupLayoutSegmentedControl];
    [self setupCollectionView];
        
    [self addObservers];
    [self getPhotoURLsForPage:currentPage];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillLayoutSubviews {
    self.collectionView.frame = CGRectMake(self.view.bounds.origin.x,
                                           self.view.bounds.origin.y + kLayoutSegmentedControlHeight,
                                           self.view.bounds.size.width,
                                           self.view.bounds.size.height - kLayoutSegmentedControlHeight);
    self.layoutSegmentedControl.frame = CGRectMake(self.view.bounds.origin.x,
                                                   self.view.bounds.origin.y,
                                                   kLayoutSegmentedControlHeight * 2,
                                                   kLayoutSegmentedControlHeight);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDarkContent;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [self removeObservers];
}


#pragma mark - Private methods

- (void)getPhotoURLsForPage:(NSInteger)pageNum {
    [PublicPhotoManager.sharedPublicPhotoManager getPublicPhotoURLsWithPage:pageNum
                                                             completionHandler:^(NSMutableArray<Photo *> * _Nullable photosFetched,
                                                                                 NSError * _Nullable error) {
        NSLog(@"[DEBUG] %s : API called!", __func__);
        if (error) {
            switch (error.code) {
                case kNetworkError:
                    // Network error view
                    NSLog(@"[DEBUG] %s : No internet connection", __func__);
                    [NSNotificationCenter.defaultCenter postNotificationName:@"NetworkErrorPublic"
                                                                      object:self];
                    break;
                case kNoDataError:
                    // No data error view
                    NSLog(@"[DEBUG] %s : No data error, try again", __func__);
                    [NSNotificationCenter.defaultCenter postNotificationName:@"NoDataErrorPublic"
                                                                      object:self];
                    break;
                default:
                    // Error occur view
                    NSLog(@"[DEBUG] %s : Something went wrong", __func__);
                    [NSNotificationCenter.defaultCenter postNotificationName:@"ServerErrorPublic"
                                                                      object:self];

                    break;
            }
            return;
        }
        
        if (photosFetched.count == 0) {
            isLastPage = YES;
        }
        [self.photos addObjectsFromArray:photosFetched];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];
}

#pragma mark - DynamicCollectionViewLayoutDataSource
- (CGSize)dynamicCollectionViewLayout:(DynamicCollectionViewLayout *)layout
         originalImageSizeAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.photos.count) {
        Photo *photo = self.photos[indexPath.row];
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

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PublicPhotoCollectionViewCell *cell = [collectionView
                                            dequeueReusableCellWithReuseIdentifier:[PublicPhotoCollectionViewCell reuseIdentifier]
                                            forIndexPath:indexPath];
    
    Photo *photo = self.photos[indexPath.row];
    NSUUID *identifier = photo.identifier;
    NSURL *url = photo.imageURL;
    cell.representedIdentifier = identifier;
    
    UIImage *fetchedData = [self.asyncFetcher fetchedDataForIdentifier:identifier];
    // Check if the `asyncFetcher` has already fetched data for the specified identifier.
    if (fetchedData != nil) {
        // The data has already been fetched and cached; use it to configure the cell.
        [cell configureWithImage:fetchedData];
    } else {
        // There is no data available; clear the cell until we've fetched data.
        [cell configureWithImage:nil];
        
        // Ask the `asyncFetcher` to fetch data for the specified identifier
        [self.asyncFetcher fetchAsyncForIdentifier:identifier
                                          imageURL:url
                                        completion:^(UIImage * _Nullable data) {
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                /*
                 The `asyncFetcher` has fetched data for the identifier. Before
                 updating the cell, check if it has been recycled by the
                 collection view to represent other data.
                 */
                if (cell.representedIdentifier != identifier) return;
                
                // Configure the cell with the fetched image
//                NSLog(@"[DEBUG] gonna go: %@", indexPath);
                [cell configureWithImage:data];
                [self.dynamicLayout clearCacheAfterIndexPath:indexPath];
                [UIView animateWithDuration:0.5f animations:^{
                    [self.collectionView.collectionViewLayout invalidateLayout];
                }];
            });
        }];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.photos.count - numOfPhotosBeforeNewFetch && !isLastPage) {
        currentPage += 1;
        NSLog(@"[DEBUG] %s : API called!", __func__);
        [self getPhotoURLsForPage:currentPage];
    }
}

#pragma mark - <UICollectionViewDataSourcePrefetching>
/// Tag: Prefetching
- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
//        NSLog(@"[DEBUG] prefetch for indexPath: %@", indexPath);
        Photo *photo = self.photos[indexPath.row];
        [self.asyncFetcher fetchAsyncForIdentifier:photo.identifier
                                          imageURL:photo.imageURL
                                        completion:nil];
    }
}

/// Tag: Cancel Prefetching
- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    // Cancle any in-flight requests for data for the specified index paths
    for (NSIndexPath *indexPath in indexPaths) {
        Photo *photo = self.photos[indexPath.row];
        [self.asyncFetcher cancelFetchForIdentifier:photo.identifier];
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
- (void)addObservers {
    [NSNotificationCenter.defaultCenter addObserverForName:@"NetworkErrorPublic"
                                                    object:nil
                                                     queue:NSOperationQueue.mainQueue
                                                usingBlock:^(NSNotification *notification) {
        
        NetworkErrorViewController *networkErrorVC = [[NetworkErrorViewController alloc] init];
        networkErrorVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        networkErrorVC.view.frame = self.view.bounds;
        networkErrorVC.delegate = self;
        [self.navigationController pushViewController:networkErrorVC animated:NO];
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:@"ServerErrorPublic"
                                                    object:nil
                                                     queue:NSOperationQueue.mainQueue
                                                usingBlock:^(NSNotification *notification) {
        
        ServerErrorViewController *serverErrorVC = [[ServerErrorViewController alloc] init];
        serverErrorVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        serverErrorVC.view.frame = self.view.bounds;
        serverErrorVC.delegate = self;
        [self.navigationController pushViewController:serverErrorVC animated:NO];
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:@"NoDataErrorPublic"
                                                    object:nil
                                                     queue:NSOperationQueue.mainQueue
                                                usingBlock:^(NSNotification *notification) {
        
        NoDataErrorViewController *noDataErrorVC = [[NoDataErrorViewController alloc] init];
        noDataErrorVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        noDataErrorVC.view.frame = self.navigationController.view.bounds;
        noDataErrorVC.delegate = self;

        [self.navigationController pushViewController:noDataErrorVC animated:NO];
    }];
}

- (void)removeObservers {
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"NetworkErrorPublic" object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"ServerErrorPublic" object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"NoDataErrorPublic" object:nil];
}

- (void)setupLayoutSegmentedControl {
    [self.layoutSegmentedControl removeAllSegments];
    UIImage *dynamicLayoutIcon = [[UIImage imageNamed:@"ic_dynamic_layout_outlined"]
                                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *fixedLayoutIcon = [[UIImage imageNamed:@"ic_fixed_layout_outlined"]
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];


    [self.layoutSegmentedControl insertSegmentWithImage:dynamicLayoutIcon
                                                atIndex:dynamicLayoutIdx
                                               animated:NO];
    [self.layoutSegmentedControl insertSegmentWithImage:fixedLayoutIcon
                                                atIndex:fixedLayoutIdx
                                               animated:NO];
    [self.layoutSegmentedControl addTarget:self
                              action:@selector(onSegmentedSelectionChanged:)
                    forControlEvents:UIControlEventValueChanged];
    self.layoutSegmentedControl.selectedSegmentIndex = dynamicLayoutIdx;
    self.layoutSegmentedControl.selectedSegmentTintColor = UIColor.systemBlueColor;
}

- (void)setupCollectionView {
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.dataSource = self;
    self.collectionView.prefetchDataSource = self;
    self.collectionView.delegate = self;
}

- (void)onSegmentedSelectionChanged:(UISegmentedControl *)segment {
    [self updateLayout];
}

- (void)updateLayout {
    if (self.layoutSegmentedControl.selectedSegmentIndex == dynamicLayoutIdx) {
        [self.collectionView setCollectionViewLayout:self.dynamicLayout animated:YES];
        [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
        if (self.photos.count > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            [self.collectionView scrollToItemAtIndexPath:indexPath
                                        atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }
    } else {
        [self.collectionView setCollectionViewLayout:self.fixedFlowLayout animated:YES];
        [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
        if (self.photos.count > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            [self.collectionView scrollToItemAtIndexPath:indexPath
                                        atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }
    }
}

#pragma mark - Custom Accessors
- (DynamicCollectionViewLayout *)dynamicLayout {
    if (_dynamicLayout) return _dynamicLayout;

    _dynamicLayout = [[DynamicCollectionViewLayout alloc] init];
    _dynamicLayout.dataSource = self;
    _dynamicLayout.fixedHeight = NO;
    _dynamicLayout.rowMaximumHeight = kCellHeight;
    return _dynamicLayout;
}

- (FixedFlowLayout *)fixedFlowLayout {
    if (_fixedFlowLayout) return _fixedFlowLayout;
    
    _fixedFlowLayout = [[FixedFlowLayout alloc] init];
    _fixedFlowLayout.itemSize = CGSizeMake(self.collectionView.bounds.size.width - _fixedFlowLayout.minimumLineSpacing * 2, kCellHeight);
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

- (AsyncImageFetcher *)asyncFetcher {
    if (_asyncFetcher) return _asyncFetcher;
    
    _asyncFetcher = [[AsyncImageFetcher alloc] init];
    return _asyncFetcher;
}

- (NSMutableArray<Photo *> *)photos {
    if (_photos) return _photos;
    
    _photos = [NSMutableArray array];
    return _photos;
}

- (NSMutableDictionary *)originalImageSize {
    if (_originalImageSize) return _originalImageSize;
    _originalImageSize = [NSMutableDictionary dictionary];
    return _originalImageSize;
}

- (UISegmentedControl *)layoutSegmentedControl {
    if (_layoutSegmentedControl) return _layoutSegmentedControl;
    _layoutSegmentedControl = [[UISegmentedControl alloc] init];
    return _layoutSegmentedControl;
}


@end
