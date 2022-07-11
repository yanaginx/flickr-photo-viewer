//
//  UploadViewController.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class UploadPhotoManager;
NS_ASSUME_NONNULL_BEGIN

@interface UploadViewController : UIViewController

- (instancetype)initWithUploadPhotoManager:(UploadPhotoManager *)uploadManager;

@end

NS_ASSUME_NONNULL_END
