//
//  GalleryManager.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 06/07/2022.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface GalleryManager : NSObject

@property (nonatomic, strong) PHFetchResult<PHAsset *> *fetchResult;
@property (nonatomic, strong) PHCachingImageManager *imageCacheManager;

- (void)fetchAssets;

- (void)getFullSizeImageByAsset:(PHAsset *)asset
              completionHandler:(void (^)(UIImage * _Nullable image))completion;

@end

NS_ASSUME_NONNULL_END
