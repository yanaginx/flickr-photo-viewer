//
//  DynamicCollectionViewLayout.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 27/06/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol DynamicCollectionViewLayoutDataSource;

@interface DynamicCollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) id <DynamicCollectionViewLayoutDataSource> dataSource;
@property CGFloat rowMaximumHeight;
@property BOOL fixedHeight;

- (CGSize)sizeForPhotoAtIndexPath:(NSIndexPath *)indexPath;
- (void)clearCache;
- (void)clearCacheAfterIndexPath:(NSIndexPath *)indexPath;

@end

@protocol DynamicCollectionViewLayoutDataSource <NSObject>

- (CGSize)dynamicCollectionViewLayout:(DynamicCollectionViewLayout *)layout
         originalImageSizeAtIndexPath:(NSIndexPath *)indexPath;

@end


