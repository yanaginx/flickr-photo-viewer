//
//  UploadPostViewController.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 06/07/2022.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class GalleryManager;
@class UploadPhotoManager;

NS_ASSUME_NONNULL_BEGIN

@protocol UploadPostStartDelegate <NSObject>

- (void)onStartingUploadProcess;

@end

@interface UploadPostViewController : UIViewController

@property (nonatomic, strong) NSDictionary<NSString *, PHAsset *> *selectedAssets;

- (instancetype)initWithUploadPhotoManager:(UploadPhotoManager *)uploadManager
                            galleryManager:(GalleryManager *)galleryManager;

@end

NS_ASSUME_NONNULL_END
