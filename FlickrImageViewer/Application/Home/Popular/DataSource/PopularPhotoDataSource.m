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
    NSUUID *identifier = [self.popularPhotoViewModel identifierAtIndexPath:indexPath];
    NSURL *url = [self.popularPhotoViewModel itemAtIndexPath:indexPath];;
    if (identifier == nil || url == nil) return cell;
    
    cell.representedIdentifier = identifier;
    UIImage *fetchedData = [self.asyncFetcher fetchedDataForIdentifier:identifier];
    if (fetchedData != nil) {
        [cell configureWithImage:fetchedData];
    } else {
        [cell configureWithImage:nil];
        [self.asyncFetcher fetchAsyncForIdentifier:identifier
                                          imageURL:url
                                        completion:^(UIImage * _Nullable data) {
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                if (cell.representedIdentifier != identifier) return;
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
        NSUUID *identifier = [self.popularPhotoViewModel identifierAtIndexPath:indexPath];
        NSURL *url = [self.popularPhotoViewModel itemAtIndexPath:indexPath];
        [self.asyncFetcher fetchAsyncForIdentifier:identifier
                                          imageURL:url
                                        completion:nil];
    }
}

/// Tag: Cancel Prefetching
- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        NSUUID *identifier = [self.popularPhotoViewModel identifierAtIndexPath:indexPath];
        [self.asyncFetcher cancelFetchForIdentifier:identifier];
    }
}

#pragma mark - Custom Accessors
- (AsyncImageFetcher *)asyncFetcher {
    if (_asyncFetcher) return _asyncFetcher;
    
    _asyncFetcher = [[AsyncImageFetcher alloc] init];
    return _asyncFetcher;
}

@end
