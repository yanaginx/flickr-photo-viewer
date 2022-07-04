//
//  AlbumInfoDataSource.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 04/07/2022.
//

#import "AlbumInfoDataSource.h"
#import "../../Views/AlbumInfoCollectionViewCell.h"

@implementation AlbumInfoDataSource

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumInfoCollectionViewCell *cell = [collectionView
                                         dequeueReusableCellWithReuseIdentifier:[AlbumInfoCollectionViewCell reuseIdentifier]
                                         forIndexPath:indexPath];
    return cell;
}

@end
