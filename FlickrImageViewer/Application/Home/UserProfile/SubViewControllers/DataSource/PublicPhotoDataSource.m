//
//  PublicPhotoDataSource.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 02/07/2022.
//

#import "PublicPhotoDataSource.h"
#import "../../../../../Common/Utilities/AsyncFetcher/AsyncImageFetcher.h"
#import "../../../../../Common/Extensions/UIImageView+Additions.h"
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
    NSURL *url = photo.imageURL;
    if (url == nil) return cell;
    [cell.photoImageView setImageUsingURL:url];
    return cell;
}

//#pragma mark - <UICollectionViewDataSourcePrefetching>
///// Tag: Prefetching
//- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
//    for (NSIndexPath *indexPath in indexPaths) {
//        Photo *photo = self.photos[indexPath.row];
//        [self.asyncFetcher fetchAsyncForIdentifier:photo.identifier
//                                          imageURL:photo.imageURL
//                                        completion:nil];
//    }
//}
//
///// Tag: Cancel Prefetching
//- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
//    for (NSIndexPath *indexPath in indexPaths) {
//        Photo *photo = self.photos[indexPath.row];
//        [self.asyncFetcher cancelFetchForIdentifier:photo.identifier];
//    }
//}

#pragma mark - Custom Accessors
//- (AsyncImageFetcher *)asyncFetcher {
//    if (_asyncFetcher) return _asyncFetcher;
//    
//    _asyncFetcher = [[AsyncImageFetcher alloc] init];
//    return _asyncFetcher;
//}

- (NSMutableArray<Photo *> *)photos {
    if (_photos) return _photos;
    
    _photos = [NSMutableArray array];
    return _photos;
}

@end
