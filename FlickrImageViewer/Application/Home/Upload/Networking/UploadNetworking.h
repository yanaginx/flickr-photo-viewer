//
//  UploadNetworking.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 11/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UploadNetworking : NSObject

- (void)uploadUserImage:(UIImage *)image
                  title:(NSString *)imageName
            description:(NSString *)imageDescription
      completionHandler:(void (^)(NSString *  _Nullable uploadedPhotoID,
                                  NSError * _Nullable error))completion;

- (void)addPhotoID:(NSString *)photoID
         toAlbumID:(NSString *)albumID
 completionHandler:(void (^)(NSString *  _Nullable status,
                             NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
