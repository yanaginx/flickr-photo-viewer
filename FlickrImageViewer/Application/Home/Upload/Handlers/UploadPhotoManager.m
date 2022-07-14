//
//  UploadPhotoManager.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 05/07/2022.
//

#import "UploadPhotoManager.h"
#import "GalleryManager.h"
#import "../Networking/UploadNetworking.h"
#import "../Networking/UploadTask.h"
#import "../Networking/UploadInfo.h"

#import "../../../../Common/Constants/Constants.h"
#import "../../../../Common/Utilities/Scope/Scope.h"

#define kDefaultTitle @"Default title"
#define kDefaultDescription @"Default description"
#define kMaxAsyncUploadTask 10

@interface UploadPhotoManager () {
    dispatch_queue_t serialUploadQueue;
    NSInteger numberOfPhotosUploaded;
    NSInteger numberOfPhotosOnLastBatch;
    dispatch_queue_t uploadQueue;
    dispatch_group_t uploadGroup;
    dispatch_semaphore_t uploadSemaphore;
    NSMutableArray *uploadTasks;
}

// A queue to hold the current requests
// @property (strong) NSArray<PHAsset *> *imageAssetsExecuting;

@property (nonatomic, strong) NSArray<PHAsset *> *imageAssetsForUpload;
@property (nonatomic, strong) PHCachingImageManager *imageCacheManager;
@property (nonatomic, strong) UploadNetworking *uploadNetworking;

@end

@implementation UploadPhotoManager

- (instancetype)init {
    self = [super init];
    if (self) {
        serialUploadQueue = dispatch_queue_create("serial_upload_queue", DISPATCH_QUEUE_SERIAL);
        uploadQueue = dispatch_queue_create("vng.duongvc.upload", DISPATCH_QUEUE_CONCURRENT);
        uploadGroup = dispatch_group_create();
        uploadSemaphore = dispatch_semaphore_create(10);
        uploadTasks = [NSMutableArray array];
        numberOfPhotosUploaded = 0;
        numberOfPhotosOnLastBatch = 0;
    }
    return self;
}

#pragma mark - Public methods

- (void)uploadSelectedImages:(NSArray<PHAsset *> *)imageAssets
                   withTitle:(NSString *)title
                 description:(NSString *)description
                     albumID:(NSString *)albumID {
    // Call the delegate to start the pop over
    [self.delegate onStartUploadingImage];
    // Create upload tasks
    for (PHAsset *imageAsset in imageAssets) {
        dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.synchronous = YES;
            [self.imageCacheManager requestImageForAsset:imageAsset
                                              targetSize:PHImageManagerMaximumSize
                                             contentMode:PHImageContentModeAspectFill
                                                 options:options
                                           resultHandler:^(UIImage * _Nullable result,
                                                           NSDictionary * _Nullable info) {
                //            NSLog(@"[DEBUG] %s: image info: %@",
                //                  __func__,
                //                  result);
                //
                if (result) {
                    UploadInfo *uploadInfo = [[UploadInfo alloc] initWithImage:result
                                                                         title:title
                                                                   description:description
                                                                       albumID:albumID];
                    UploadTask *uploadTask = [[UploadTask alloc] initWithTaskIdentifier:[[NSUUID alloc] init]
                                                                     stateUpdateHandler:^(UploadTask * _Nonnull uploadTask) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            switch (uploadTask.state) {
                                case UploadTaskStateCompleted:
                                    [self.delegate onFinishUploadingImageWithErrorCode:kNoError];
                                    break;
                                case UploadTaskStateCompletedWithError:
                                    [self.delegate onFinishUploadingImageWithErrorCode:kServerError];
                                    break;
                                default:
                                    break;
                            }
                        });
                    }
                                                                             uploadInfo:uploadInfo];
                    //                uploadTask.taskIdentifier = [[NSUUID alloc] init];
                    //                uploadTask.uploadInfo = uploadInfo;
                    //                uploadTask.stateUpdateHandler = ^(UploadTask * _Nonnull uploadTask) {
                    //                };
                    [self->uploadTasks addObject:uploadTask];
                }
            }];
        });
    }
//        NSLog(@"[DEBUG] %s: title: %@\ndescription: %@\nalbumID: %@",
//              __func__,
//              title,
//              description,
//              albumID);
    
    // Start the upload tasks
    for (UploadTask *uploadTask in uploadTasks) {
//        NSLog(@"[DEBUG] %s: upload task image: %@", __func__, uploadTask.uploadInfo.image);
        [uploadTask startUploadTaskWithQueue:self->uploadQueue
                                       group:self->uploadGroup
                                   semaphore:self->uploadSemaphore];
    }
    [uploadTasks removeAllObjects];
    // This is being called everytime a new batch is started
    @weakify(self)
    dispatch_group_notify(uploadGroup, dispatch_get_main_queue(), ^{
        @strongify(self)
        [self.delegate onFinishUploadingImageWithErrorCode:kLastPhotoUploaded];
        NSLog(@"[DEBUG] %s: all photos uploaded", __func__);
    });
}

- (void)_uploadUserImage:(UIImage *)image
               withTitle:(NSString *)title
             description:(NSString *)description
                 albumID:(NSString *)albumID {
    @weakify(self)
    [self.uploadNetworking uploadUserImage:image
                                     title:title
                               description:description
                         completionHandler:^(NSString * _Nullable uploadedPhotoID,
                                             NSError * _Nullable error) {
        @strongify(self);
        if (error) {
            [self.delegate onFinishUploadingImageWithErrorCode:error.code];
            return;
        }
        // add the image to album if the albumID is
        // TODO:
        if (albumID != nil) {
            [self _addImageWithID:uploadedPhotoID
                        toAlbumID:albumID];
        } else {
            self->numberOfPhotosUploaded += 1;
            if (self->numberOfPhotosUploaded == self.imageAssetsForUpload.count) {
                [self.delegate onFinishUploadingImageWithErrorCode:kLastPhotoUploaded];
            } else {
                [self.delegate onFinishUploadingImageWithErrorCode:kNoError];
            }
        }
    }];
}



- (void)_addImageWithID:(NSString *)photoID
              toAlbumID:(NSString *)albumID {
    // TODO: Implement the func
    @weakify(self)
    [self.uploadNetworking addPhotoID:photoID
                            toAlbumID:albumID
                    completionHandler:^(NSString * _Nullable status,
                                        NSError * _Nullable error) {
        @strongify(self)
        if (error) {
            [self.delegate onFinishUploadingImageWithErrorCode:error.code];
            return;
        }
        self->numberOfPhotosUploaded += 1;
        if (self->numberOfPhotosUploaded == self->numberOfPhotosOnLastBatch) {
            [self.delegate onFinishUploadingImageWithErrorCode:kLastPhotoUploaded];
        } else {
            [self.delegate onFinishUploadingImageWithErrorCode:kNoError];
        }
    }];
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
