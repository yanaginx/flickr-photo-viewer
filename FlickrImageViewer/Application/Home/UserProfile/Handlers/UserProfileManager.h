//
//  UserProfileManager.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 01/07/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Photo;

@interface UserProfileManager : NSObject

@property (class, nonnull, readonly, strong) UserProfileManager *sharedUserProfileManager;

- (void)getPublicPhotoURLsWithPage:(NSInteger)pageNum
                 completionHandler:(void (^)(NSMutableArray<Photo *> * _Nullable photos,
                                             NSError * _Nullable error))completion;

- (void)getUserProfileWithCompletionHandler:(void (^)(NSURL * _Nullable avatarURL,
                                                      NSString * _Nullable name,
                                                      NSString * _Nullable numberOfPhotos,
                                                      NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
