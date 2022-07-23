//
//  GalleryManager.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 06/07/2022.
//

#import "GalleryManager.h"

@implementation GalleryManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [self fetchAssets];
    }
    return self;
}

#pragma mark - Operations
- (void)fetchAssets {
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate"
                                                             ascending:NO]];
    self.fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage
                                                 options:option];
}

- (void)getFullSizeImageByAsset:(PHAsset *)asset
              completionHandler:(void (^)(UIImage * _Nullable image))completion {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    [self.imageCacheManager requestImageForAsset:asset
                                      targetSize:PHImageManagerMaximumSize
                                     contentMode:PHImageContentModeAspectFill
                                         options:options
                                   resultHandler:^(UIImage * _Nullable result,
                                                   NSDictionary * _Nullable info) {
        if (result) {
            completion(result);
        }
    }];
}

#pragma mark - Custom Accessors
- (PHCachingImageManager *)imageCacheManager {
    if (_imageCacheManager) return _imageCacheManager;
    
    _imageCacheManager = [[PHCachingImageManager alloc] init];
    return _imageCacheManager;
}

- (PHFetchResult<PHAsset *> *)fetchResult {
    if (_fetchResult) return _fetchResult;
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate"
                                                             ascending:NO]];
    _fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage
                                             options:option];
    return _fetchResult;
}

@end
