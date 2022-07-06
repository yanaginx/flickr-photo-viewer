//
//  UploadPhotoManager.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 05/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UploadPhotoManager : NSObject

- (void)uploadUserImage:(UIImage *)image
                  title:(NSString *)imageName
            description:(NSString *)imageDescription
      completionHandler:(void (^)(NSString *  _Nullable,
                                  NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
