//
//  UploadPhotoManager.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 05/07/2022.
//

#import "UploadPhotoManager.h"
#import "GalleryManager.h"
#import "../Networking/UploadNetworking.h"

#import "../../../../Common/Constants/Constants.h"

#define kDefaultTitle @"Default title"
#define kDefaultDescription @"Default description"

@interface UploadPhotoManager ()

@property (nonatomic, strong) NSArray<PHAsset *> *imageAssetsForUpload;
@property (nonatomic, strong) PHCachingImageManager *imageCacheManager;
@property (nonatomic, strong) UploadNetworking *uploadNetworking;

@end

@implementation UploadPhotoManager

#pragma mark - Public methods

- (void)uploadSelectedImages:(NSArray<PHAsset *> *)imageAssets
                   withTitle:(NSString *)title
                 description:(NSString *)description
                     albumID:(NSString *)albumID {
    dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        for (PHAsset *imageAsset in imageAssets) {
            // fetch full size image to gallery into image
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.synchronous = YES;
            [self.imageCacheManager requestImageForAsset:imageAsset
                                              targetSize:PHImageManagerMaximumSize
                                             contentMode:PHImageContentModeAspectFill
                                                 options:options
                                           resultHandler:^(UIImage * _Nullable result,
                                                           NSDictionary * _Nullable info) {
                NSLog(@"[DEBUG] %s: image info: %@",
                      __func__,
                      result);
                if (result) {
                    [self _uploadUserImage:result
                                 withTitle:title
                               description:description
                                   albumID:albumID];
                }
            }];
        }
        NSLog(@"[DEBUG] %s: title: %@\ndescription: %@\nalbumID: %@",
              __func__,
              title,
              description,
              albumID);
    });
}

- (void)_uploadUserImage:(UIImage *)image
               withTitle:(NSString *)title
             description:(NSString *)description
                 albumID:(NSString *)albumID {
    [self.uploadNetworking uploadUserImage:image
                                     title:title
                               description:description
                         completionHandler:^(NSString * _Nullable uploadedPhotoID,
                                             NSError * _Nullable error) {
        if (error) {
            [self.delegate onFinishUploadingImageWithErrorCode:error.code];
            return;
        }
        [self.delegate onFinishUploadingImageWithErrorCode:0];
        // add the image to album if the albumID is
        // TODO
    }];
}



- (void)_addImageWithID:(NSString *)photoID
              toAlbumID:(NSString *)albumID {
   // TODO:
}


- (NSURLRequest *)_addPhotoToAlbumURLRequestWithPhotoID:(NSString *)photoID
                                                albumID:(NSString *)albumID {
    // TODO:
    return nil;
}

#pragma mark - Custom Accessors
- (PHCachingImageManager *)imageCacheManager {
    if (_imageCacheManager) return _imageCacheManager;
    
    _imageCacheManager = [[PHCachingImageManager alloc] init];
    return _imageCacheManager;
}

- (UploadNetworking *)uploadNetworking {
    if (_uploadNetworking) return _uploadNetworking;
    
    _uploadNetworking = [[UploadNetworking alloc] init];
    return _uploadNetworking;
}

@end
