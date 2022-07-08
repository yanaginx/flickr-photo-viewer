//
//  UploadPostViewController.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 06/07/2022.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class GalleryManager;

NS_ASSUME_NONNULL_BEGIN

@interface UploadPostViewController : UIViewController

@property (nonatomic, strong) NSDictionary<NSString *, PHAsset *> *selectedAssets;
@property (nonatomic, strong) GalleryManager *galleryManager;

@end

NS_ASSUME_NONNULL_END
