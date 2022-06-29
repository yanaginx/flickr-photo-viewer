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

#import "Views/PopularPhotoCollectionViewCell.h"
#import "DataModel/Photo.h"


@interface PopularViewController () <DynamicCollectionViewLayoutDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching>

@property (nonatomic, strong) NSMutableArray<NSURL *> *photoURLs;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) DynamicCollectionViewLayout *dynamicLayout;
// cache for getting the image size
@property (nonatomic, strong) NSCache<NSUUID *, UIImage *> *photoImagesCache;
@property (nonatomic, strong) NSMutableArray<Photo *> *photos;
@property (nonatomic, strong) AsyncImageFetcher *asyncFetcher;

@end

@implementation PopularViewController

static NSInteger currentPage = 1;
static NSInteger totalPage = 5;
static NSInteger numOfPhotosBeforeNewFetch = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.cyanColor;
    [self.view addSubview:self.collectionView];
    self.collectionView.frame = self.view.bounds;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.dataSource = self;
    self.collectionView.prefetchDataSource = self;
    self.collectionView.delegate = self;
    
    [self getPhotoURLsForPage:currentPage];
}


#pragma mark - Private methods

- (void)getPhotoURLsForPage:(NSInteger)pageNum {
    [PopularPhotoManager.sharedPopularPhotoManager getPopularPhotoURLsWithPage:pageNum
                                                             completionHandler:^(NSMutableArray<NSURL *> * _Nullable photoURLs,
                                                                                 NSError * _Nullable error) {
        if (error) {
            switch (error.code) {
                case kNetworkError:
                    // Network error view
                    NSLog(@"[DEBUG] %s : No internet connection", __func__);
                    break;
                case kNoDataError:
                    // No data error view
                    NSLog(@"[DEBUG] %s : No data error, try again", __func__);
                    break;
                default:
                    // Error occur view
                    NSLog(@"[DEBUG] %s : Something went wrong", __func__);
                    break;
            }
            return;
        }
        for (NSURL *url in photoURLs) {
//            NSLog(@"[DEBUG] url: %@", url.absoluteString);
            Photo *photo = [[Photo alloc] initWithImageURL:url];
            [self.photos addObject:photo];
        }
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
        UIImage *photoImage = [self.asyncFetcher.cache objectForKey:photo.identifier];
        if (photoImage) return photoImage.size;
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

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PopularPhotoCollectionViewCell *cell = [collectionView
                                            dequeueReusableCellWithReuseIdentifier:[PopularPhotoCollectionViewCell reuseIdentifier]
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
    if (currentPage < totalPage &&
        indexPath.row == self.photos.count - numOfPhotosBeforeNewFetch) {
        currentPage += 1;
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


#pragma mark - Custom Accessors
- (DynamicCollectionViewLayout *)dynamicLayout {
    if (_dynamicLayout) return _dynamicLayout;

    _dynamicLayout = [[DynamicCollectionViewLayout alloc] init];
    _dynamicLayout.dataSource = self;
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


@end
