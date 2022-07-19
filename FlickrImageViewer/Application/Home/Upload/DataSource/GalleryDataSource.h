//
//  GalleryDataSource.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 06/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>


@class GalleryManager;
NS_ASSUME_NONNULL_BEGIN

@interface GalleryDataSource : NSObject <UICollectionViewDataSource,
                                         PHPhotoLibraryChangeObserver>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) GalleryManager *galleryManager;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PHAsset *> *selectedAssets;

@end

NS_ASSUME_NONNULL_END
