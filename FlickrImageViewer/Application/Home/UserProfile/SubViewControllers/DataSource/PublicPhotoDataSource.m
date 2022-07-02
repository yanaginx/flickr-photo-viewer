//
//  PublicPhotoDataSource.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 02/07/2022.
//

#import "PublicPhotoDataSource.h"
#import "../../../../../Common/Utilities/AsyncFetcher/AsyncImageFetcher.h"
#import "../../../../../Models/Photo.h"
#import "../../Views/PublicPhotoCollectionViewCell.h"

@interface PublicPhotoDataSource ()

@property (nonatomic, strong) AsyncImageFetcher *asyncFetcher;

@end

@implementation PublicPhotoDataSource

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
                [cell configureWithImage:data];
            });
        }];
    }
    return cell;
}

#pragma mark - <UICollectionViewDataSourcePrefetching>
/// Tag: Prefetching
- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        Photo *photo = self.photos[indexPath.row];
        [self.asyncFetcher fetchAsyncForIdentifier:photo.identifier
                                          imageURL:photo.imageURL
                                        completion:nil];
    }
}

/// Tag: Cancel Prefetching
- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        Photo *photo = self.photos[indexPath.row];
        [self.asyncFetcher cancelFetchForIdentifier:photo.identifier];
    }
}

#pragma mark - Custom Accessors
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
