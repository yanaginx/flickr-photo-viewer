//
//  AlbumInfoDataSource.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 04/07/2022.
//

#import "AlbumInfoDataSource.h"
#import "../../Views/AlbumInfoCollectionViewCell.h"
#import "../../../../../Models/AlbumInfo.h"

@implementation AlbumInfoDataSource

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.albumInfos.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumInfoCollectionViewCell *cell = [collectionView
                                         dequeueReusableCellWithReuseIdentifier:[AlbumInfoCollectionViewCell reuseIdentifier]
                                         forIndexPath:indexPath];
    AlbumInfo *albumInfo = self.albumInfos[indexPath.row];
    [cell configureAlbumInfoCellWithImageURL:albumInfo.albumImageURL];
    [cell configureAlbumInfoCellWithName:albumInfo.albumName];
    [cell configureAlbumInfoCellWithDateCreated:albumInfo.dateCreated];
    [cell configureAlbumInfoCellWithNumberOfPhotos:albumInfo.numberOfPhotos];
    return cell;
}

#pragma mark - Custom Accessors
- (NSMutableArray<AlbumInfo *> *)albumInfos {
    if (_albumInfos) return _albumInfos;
    
    _albumInfos = [NSMutableArray array];
    return _albumInfos;
}

@end
