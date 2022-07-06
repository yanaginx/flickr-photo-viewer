//
//  GalleryDataSource.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 06/07/2022.
//

#import "GalleryDataSource.h"
#import "../Handlers/GalleryManager.h"
#import "../Views/GalleryCollectionViewCell.h"

#define kTargetSize CGSizeMake(200, 200)

@interface GalleryDataSource ()

@property (nonatomic, strong) GalleryManager *galleryManager;

@end

@implementation GalleryDataSource


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.galleryManager.fetchResult.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GalleryCollectionViewCell *cell = [collectionView
                                       dequeueReusableCellWithReuseIdentifier:GalleryCollectionViewCell.reuseIdentifier
                                       forIndexPath:indexPath];
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    PHAsset *photoAsset = [self.galleryManager.fetchResult objectAtIndex:indexPath.item];
    cell.localIdentifier = photoAsset.localIdentifier;
    [self.galleryManager.imageCacheManager requestImageForAsset:photoAsset
                                                     targetSize:kTargetSize
                                                    contentMode:PHImageContentModeAspectFill
                                                        options:nil
                                                  resultHandler:^(UIImage * _Nullable result,
                                                                  NSDictionary * _Nullable info) {
        if ([cell.localIdentifier isEqualToString:photoAsset.localIdentifier]) {
            [cell configureWithImage:result];
        }
    }];
    return cell;
}

#pragma mark - UICollectionViewDataPrefetching
//- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
//    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
//    for (NSIndexPath *indexPath in indexPaths) {
//        [assets addObject:[self.galleryManager.fetchResult objectAtIndex:indexPath.item]];
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.galleryManager.imageCacheManager startCachingImagesForAssets:assets
//                                                                targetSize:kTargetSize
//                                                               contentMode:PHImageContentModeAspectFill
//                                                                   options:nil];
//    });
//}
//
//- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
//     NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
//    for (NSIndexPath *indexPath in indexPaths) {
//        [assets addObject:[self.galleryManager.fetchResult objectAtIndex:indexPath.item]];
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.galleryManager.imageCacheManager stopCachingImagesForAssets:assets
//                                                               targetSize:kTargetSize
//                                                              contentMode:PHImageContentModeAspectFill
//                                                                  options:nil];
//    });
//}

#pragma mark - Custom Accessors
- (GalleryManager *)galleryManager {
    if (_galleryManager) return _galleryManager;
    
    _galleryManager = [[GalleryManager alloc] init];
    return _galleryManager;
}

@end
