//
//  UploadTask.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 14/07/2022.
//

#import "../../../../Common/Utilities/Scope/Scope.h"
#import "UploadTask.h"
#import "UploadNetworking.h"
#import "UploadInfo.h"

#define kKeyPath @"state"

static void * const UploadTaskContext = (void*)&UploadTaskContext;

@interface UploadTask ()

@property (nonatomic, strong) UploadNetworking *uploadNetworking;

@end

@implementation UploadTask

#pragma mark - Initialization
- (instancetype)initWithTaskIdentifier:(NSUUID *)identifier
                    stateUpdateHandler:(StateUpdateHandler)stateUpdateHandler
                            uploadInfo:(UploadInfo *)uploadInfo {
    self = [self init];
    if (self) {
        self.taskIdentifier = identifier;
        self.stateUpdateHandler = stateUpdateHandler;
        self.uploadInfo = uploadInfo;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // add observer for state change
        [self addObserver:self
               forKeyPath:kKeyPath
                  options:NSKeyValueObservingOptionNew
                  context:UploadTaskContext];
        //
        self.taskIdentifier = [[NSUUID alloc] init];
    }
    return self;
}

#pragma mark - Deallocation
- (void)dealloc {
    // clear the observer
    [self removeObserver:self
              forKeyPath:kKeyPath
                 context:UploadTaskContext];
}

#pragma mark - Public methods
- (void)startUploadTaskWithQueue:(dispatch_queue_t)dispatchQueue
                           group:(dispatch_group_t)dispatchGroup
                       semaphore:(dispatch_semaphore_t)dispatchSemaphore {
    dispatch_group_enter(dispatchGroup);
    dispatch_semaphore_wait(dispatchSemaphore, DISPATCH_TIME_FOREVER);
//    @weakify(self)
    dispatch_async(dispatchQueue, ^{
//        @strongify(self)
        self.state = UploadTaskStateInProgress;
        [self.uploadNetworking uploadUserImage:self.uploadInfo.image
                                         title:self.uploadInfo.imageTitle
                                   description:self.uploadInfo.imageDescription
                             completionHandler:^(NSString * _Nullable uploadedPhotoID,
                                                 NSError * _Nullable error) {
            // Signal the task completion with error
            if (error) {
                self.state = UploadTaskStateCompletedWithError;
                dispatch_group_leave(dispatchGroup);
                dispatch_semaphore_signal(dispatchSemaphore);
                return;
            }
            // Signal the task completion since no album id specified
            if (uploadedPhotoID && self.uploadInfo.albumID == nil) {
                self.state = UploadTaskStateCompleted;
                dispatch_group_leave(dispatchGroup);
                dispatch_semaphore_signal(dispatchSemaphore);
                return;
            }
            @weakify(self)
            [self.uploadNetworking addPhotoID:uploadedPhotoID
                                    toAlbumID:self.uploadInfo.albumID
                            completionHandler:^(NSString * _Nullable status, NSError * _Nullable error) {
                @strongify(self)
                if (error) {
                    self.state = UploadTaskStateCompletedWithError;
                    dispatch_group_leave(dispatchGroup);
                    dispatch_semaphore_signal(dispatchSemaphore);
                }
                self.state = UploadTaskStateCompleted;
                dispatch_group_leave(dispatchGroup);
                dispatch_semaphore_signal(dispatchSemaphore);
            }];
        }];
    });
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (context == UploadTaskContext) {
        self.stateUpdateHandler(self);
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma mark - Lazy loading
- (UploadNetworking *)uploadNetworking {
    if (_uploadNetworking) return _uploadNetworking;
    
    _uploadNetworking = [[UploadNetworking alloc] init];
    return _uploadNetworking;
}

@end
