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
    cell.photoAssetIdentifier = photoAsset.localIdentifier;
    [self.galleryManager.imageCacheManager requestImageForAsset:photoAsset
                                                     targetSize:kTargetSize
                                                    contentMode:PHImageContentModeAspectFill
                                                        options:nil
                                                  resultHandler:^(UIImage * _Nullable result,
                                                                  NSDictionary * _Nullable info) {
        if ([cell.photoAssetIdentifier isEqualToString:photoAsset.localIdentifier]) {
            [cell configureWithImage:result];
        }
    }];
    return cell;
}

#pragma mark - UICollectionViewDataPrefetching
- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths) {
//        NSLog(@"Prefetching for %@", indexPath);
        [assets addObject:[self.galleryManager.fetchResult objectAtIndex:indexPath.item]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.galleryManager.imageCacheManager startCachingImagesForAssets:assets
                                                                targetSize:kTargetSize
                                                               contentMode:PHImageContentModeAspectFill
                                                                   options:nil];
    });
}

- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
     NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths) {
//        NSLog(@"Stop Prefetching for %@", indexPath);
        [assets addObject:[self.galleryManager.fetchResult objectAtIndex:indexPath.item]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.galleryManager.imageCacheManager stopCachingImagesForAssets:assets
                                                               targetSize:kTargetSize
                                                              contentMode:PHImageContentModeAspectFill
                                                                  options:nil];
    });
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)_processChanges:(PHFetchResultChangeDetails *)changes {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.galleryManager.fetchResult = changes.fetchResultAfterChanges;
        if (changes.hasIncrementalChanges) {
            [self.collectionView performBatchUpdates:^{
                NSIndexSet *removed = changes.removedIndexes;
                if (removed != nil && removed.count != 0) {
                    NSMutableArray<NSIndexPath *> *indexPathsToRemove = [NSMutableArray array];
                    [removed enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx
                                                                     inSection:0];
                        [indexPathsToRemove addObject:indexPath];
                    }];
                    [self.collectionView deleteItemsAtIndexPaths:indexPathsToRemove];
                }
                // Remove objects from selected assets
                NSArray *removedObjects = changes.removedObjects;
                for (PHAsset *removedAsset in removedObjects) {
                    if ([self.selectedAssets objectForKey:removedAsset.localIdentifier] != nil) {
                        [self.selectedAssets removeObjectForKey:removedAsset.localIdentifier];
                        NSLog(@"[DEBUG] %s : current selected assets: %lu",
                              __func__,
                              (unsigned long)self.selectedAssets.count);
                    }
                }
                NSIndexSet *inserted = changes.insertedIndexes;
                if (inserted != nil && inserted.count != 0) {
                    NSMutableArray<NSIndexPath *> *indexPathsToAdd = [NSMutableArray array];
                    [inserted enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx
                                                                     inSection:0];
                        [indexPathsToAdd addObject:indexPath];
                    }];
                    [self.collectionView insertItemsAtIndexPaths:indexPathsToAdd];
                }
                [changes enumerateMovesWithBlock:^(NSUInteger fromIndex,
                                                   NSUInteger toIndex) {
                    NSIndexPath *fromIndexPath = [NSIndexPath indexPathForItem:fromIndex
                                                                     inSection:0];
                    NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:toIndex
                                                                   inSection:0];
                    [self.collectionView moveItemAtIndexPath:fromIndexPath
                                                 toIndexPath:toIndexPath];
                }];
            } completion:nil];
            NSIndexSet *changed = changes.changedIndexes;
            if (changed != nil && changed.count != 0) {
                NSMutableArray<NSIndexPath *> *indexPathsToChange = [NSMutableArray array];
                [changed enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx
                                                                 inSection:0];
                    [indexPathsToChange addObject:indexPath];
                }];
                NSArray *changedObjects = changes.changedObjects;
                for (PHAsset *changedObject in changedObjects) {
                    if ([self.selectedAssets objectForKey:changedObject.localIdentifier] != nil) {
                        NSLog(@"[DEBUG] %s : The local identifier didnt change",
                              __func__);
                    }
                }
                [self.collectionView reloadItemsAtIndexPaths:indexPathsToChange];
                // Reselect the edited cells
                for (NSIndexPath* indexPath in indexPathsToChange) {
                    GalleryCollectionViewCell *cellToChange = (GalleryCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                    if ([self.selectedAssets objectForKey:cellToChange.photoAssetIdentifier] != nil) {
                        [self.collectionView selectItemAtIndexPath:indexPath
                                                          animated:NO
                                                    scrollPosition:UICollectionViewScrollPositionNone];
                        
                    }
                }
            }
        } else {
            [self.collectionView reloadData];
        }
    });
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    PHFetchResultChangeDetails *changes = [changeInstance changeDetailsForFetchResult:self.galleryManager.fetchResult];
    if (changes == nil) return;
    [self _processChanges:changes];
}

#pragma mark - Custom Accessors
- (GalleryManager *)galleryManager {
    if (_galleryManager) return _galleryManager;
    
    _galleryManager = [[GalleryManager alloc] init];
    return _galleryManager;
}

- (NSMutableDictionary<NSString *, PHAsset *> *)selectedAssets {
    if (_selectedAssets) return _selectedAssets;
    
    _selectedAssets = [NSMutableDictionary dictionary];
    return _selectedAssets;
}

@end
