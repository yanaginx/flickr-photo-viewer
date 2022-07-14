//
//  UploadTask.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 14/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UploadTask;
@class UploadInfo;

NS_ASSUME_NONNULL_BEGIN

typedef void (^StateUpdateHandler)(UploadTask *);

typedef NS_ENUM(NSUInteger, UploadTaskState) {
    UploadTaskStateIsPending,
    UploadTaskStateInProgress,
    UploadTaskStateCompleted,
    UploadTaskStateCompletedWithError
};

@interface UploadTask : NSObject


@property (nonatomic, strong) NSUUID *taskIdentifier;
@property (nonatomic, strong) StateUpdateHandler stateUpdateHandler;
@property (nonatomic) UploadTaskState state;
@property (nonatomic, strong) UploadInfo *uploadInfo;

- (instancetype)initWithTaskIdentifier:(NSUUID *)identifier
                    stateUpdateHandler:(StateUpdateHandler)stateUpdateHandler
                            uploadInfo:(UploadInfo *)uploadInfo;

- (void)startUploadTaskWithQueue:(dispatch_queue_t)dispatchQueue
                           group:(dispatch_group_t)dispatchGroup
                       semaphore:(dispatch_semaphore_t)dispatchSemaphore;
                        

@end

NS_ASSUME_NONNULL_END
