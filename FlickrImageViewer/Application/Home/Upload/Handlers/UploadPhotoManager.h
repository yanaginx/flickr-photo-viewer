//
//  UploadPhotoManager.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 05/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UploadPhotoManagerDelegate <NSObject>

- (void)onStartUploadingImageWithTotalTasksCount:(NSInteger)totalTasks
                              finishedTasksCount:(NSInteger)finishedTasks;
- (void)onFinishUploadingImageWithErrorCode:(NSInteger)errorCode
                            totalTasksCount:(NSInteger)totalTasks
                         finishedTasksCount:(NSInteger)finishedTasks;

@end

@interface UploadPhotoManager : NSObject

@property (nonatomic, weak) id<UploadPhotoManagerDelegate> delegate;

- (void)uploadSelectedImages:(NSArray<PHAsset *> *)imageAssets
                   withTitle:(NSString * _Nullable)title
                 description:(NSString * _Nullable)description
                     albumID:(NSString * _Nullable)albumID;
//
//- (void)uploadUserImage:(UIImage *)image
//                  title:(NSString *)imageName
//            description:(NSString *)imageDescription
//      completionHandler:(void (^)(NSString *  _Nullable,
//                                  NSError * _Nullable))completion;
//
@end

NS_ASSUME_NONNULL_END
