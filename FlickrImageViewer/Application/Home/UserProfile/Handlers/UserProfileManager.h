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

- (void)getUserProfileWithCompletionHandler:(void (^)(NSURL * _Nullable avatarURL,
                                                      NSString * _Nullable name,
                                                      NSString * _Nullable numberOfPhotos,
                                                      NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
