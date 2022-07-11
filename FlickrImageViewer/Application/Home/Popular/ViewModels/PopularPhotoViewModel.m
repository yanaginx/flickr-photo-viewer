//
//  PopularPhotoViewModel.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 10/07/2022.
//

#import "PopularPhotoViewModel.h"
#import "../Handlers/PopularPhotoManager.h"
#import "../../../../Common/Utilities/AsyncFetcher/AsyncImageFetcher.h"
#import "../../../../Common/Constants/Constants.h"

#import "../../../../Models/Photo.h"

@interface PopularPhotoViewModel () 

@property (nonatomic, strong) PopularPhotoManager *popularPhotoManager;
@property (nonatomic, strong) NSMutableArray<Photo *> *photos;
@property (nonatomic, strong) NSMutableArray<UIImage *> *photoImages;
@property (nonatomic, strong) DynamicCollectionViewLayout *dynamicCellSizeCalculator;

@end

@implementation PopularPhotoViewModel

- (instancetype)initWithDynamicLayout:(DynamicCollectionViewLayout *)dynamicLayout
                         photoManager:(PopularPhotoManager *)photoManager {
    self = [self init];
    if (self) {
        self.dynamicCellSizeCalculator = dynamicLayout;
        self.popularPhotoManager = photoManager;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.photos = [NSMutableArray array];
        self.photoImages = [NSMutableArray array];
        self.popularPhotoManager = [[PopularPhotoManager alloc] init];
    }
    return self;
}

#pragma mark - Operations

- (void)getPhotosForPage:(NSInteger)page {
    [self.popularPhotoManager getPopularPhotoURLsWithPage:page
                                        completionHandler:^(NSMutableArray<Photo *> * _Nullable photosFetched,
                                                            NSError * _Nullable error) {
        NSLog(@"[DEBUG] %s : API called!", __func__);
        if (error) {
            NSNumber *errorCodeNumber = [NSNumber numberWithInteger:error.code];
            NSNumber *isLastPageNumber = [NSNumber numberWithBool:NO];
            [self.photoFetcherdelegate onFinishGettingPhotosWithErrorCode:errorCodeNumber
                                                           lastPageStatus:isLastPageNumber];
            return;
        }
        BOOL isLastPage = NO;
        if (photosFetched.count == 0) isLastPage = YES;
        NSNumber *noErrorCodeNumber = [NSNumber numberWithInteger:0];
        NSNumber *isLastPageNumber = [NSNumber numberWithBool:isLastPage];
        [self.photos addObjectsFromArray:photosFetched];
        [self.photoFetcherdelegate onFinishGettingPhotosWithErrorCode:noErrorCodeNumber
                                                       lastPageStatus:isLastPageNumber];
    }];
}

- (NSUInteger)numberOfItems {
    return self.photos.count;
}

- (NSUInteger)numberOfSections {
    return 1;
}

- (NSURL *)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.photos.count) {
        return nil;
    }
    return self.photos[indexPath.row].imageURL;
}

- (NSUUID *)identifierAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.photos.count) {
        return nil;
    }
    return self.photos[indexPath.row].identifier;
}

- (CGSize)itemSizeAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dynamicCellSizeCalculator sizeForPhotoAtIndexPath:indexPath];
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

@end
