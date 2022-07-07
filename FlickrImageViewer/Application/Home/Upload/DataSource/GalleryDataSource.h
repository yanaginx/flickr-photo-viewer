//
//  GalleryDataSource.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 06/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface GalleryDataSource : NSObject <UICollectionViewDataSource,
                                         UICollectionViewDataSourcePrefetching,
                                         PHPhotoLibraryChangeObserver>

@property (nonatomic, weak) UICollectionView *collectionView;

@end

NS_ASSUME_NONNULL_END
