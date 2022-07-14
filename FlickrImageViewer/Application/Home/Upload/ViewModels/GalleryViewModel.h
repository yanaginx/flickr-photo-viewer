//
//  GalleryViewModel.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 14/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class GalleryManager;
NS_ASSUME_NONNULL_BEGIN

@interface GalleryViewModel : NSObject

- (NSUInteger)numberOfItems;
- (UIImage *)itemAtIndexPath:(NSIndexPath *)indexPath;

- (instancetype)initWithGalleryManager:(GalleryManager *)galleryManager;

@end

NS_ASSUME_NONNULL_END
