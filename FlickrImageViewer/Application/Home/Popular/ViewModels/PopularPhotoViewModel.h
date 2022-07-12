//
//  PopularPhotoViewModel.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 10/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../../../../Common/Layouts/DynamicLayout/DynamicCollectionViewLayout.h"

@class DynamicCollectionViewLayout;
@class PopularPhotoManager;

NS_ASSUME_NONNULL_BEGIN

@protocol PopularPhotoViewModelDelegate <NSObject>

- (void)onFinishGettingPhotosWithErrorCode:(NSNumber *)errorCode
                            lastPageStatus:(NSNumber *)isLastPage;

@end

@interface PopularPhotoViewModel : NSObject <DynamicCollectionViewLayoutDataSource>

@property (nonatomic, weak) id<PopularPhotoViewModelDelegate> photoFetcherdelegate;

- (NSUInteger)numberOfItems;
- (NSUInteger)numberOfSections;
- (NSURL *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSUUID *)identifierAtIndexPath:(NSIndexPath *)indexPath;
- (CGSize) itemSizeAtIndexPath:(NSIndexPath *)indexPath;

- (void)getPhotosForPage:(NSInteger)page;

- (void)removeAllPhotos;

- (instancetype)initWithDynamicLayout:(DynamicCollectionViewLayout *)dynamicLayout
                         photoManager:(PopularPhotoManager *)photoManager;

@end

NS_ASSUME_NONNULL_END
