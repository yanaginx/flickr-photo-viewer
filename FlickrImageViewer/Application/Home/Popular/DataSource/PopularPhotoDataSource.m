//
//  PopularPhotoDataSource.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 02/07/2022.
//

#import "PopularPhotoDataSource.h"
#import "../../../../Common/Utilities/AsyncFetcher/AsyncImageFetcher.h"
#import "../../../../Models/Photo.h"

#import "../ViewModels/PopularPhotoViewModel.h"
#import "../Views/PopularPhotoCollectionViewCell.h"

@interface PopularPhotoDataSource ()

@property (nonatomic, strong) AsyncImageFetcher *asyncFetcher;

@end


@implementation PopularPhotoDataSource

#pragma mark - Initialization
- (instancetype)initWithViewModel:(PopularPhotoViewModel *)viewModel {
    self = [super init];
    if (self) {
        self.popularPhotoViewModel = viewModel;
    }
    return self;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.popularPhotoViewModel.numberOfItems;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PopularPhotoCollectionViewCell *cell = [collectionView
                                            dequeueReusableCellWithReuseIdentifier:[PopularPhotoCollectionViewCell reuseIdentifier]
                                            forIndexPath:indexPath];
    NSURL *imageURL = [self.popularPhotoViewModel itemAtIndexPath:indexPath];
    if (imageURL == nil) return cell;
    [cell configureWithImageURL:imageURL];
    return cell;
}


//#pragma mark - <UICollectionViewDataSourcePrefetching>
///// Tag: Prefetching
//- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
//    for (NSIndexPath *indexPath in indexPaths) {
//        NSString *identifier = [self.popularPhotoViewModel identifierAtIndexPath:indexPath];
//        NSURL *url = [self.popularPhotoViewModel itemAtIndexPath:indexPath];
//        [self.asyncFetcher fetchAsyncForIdentifier:identifier
//                                          imageURL:url
//                                        completion:nil];
//    }
//}
//
///// Tag: Cancel Prefetching
//- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
//    for (NSIndexPath *indexPath in indexPaths) {
//        NSString *identifier = [self.popularPhotoViewModel identifierAtIndexPath:indexPath];
//        [self.asyncFetcher cancelFetchForIdentifier:identifier];
//    }
//}

@end
