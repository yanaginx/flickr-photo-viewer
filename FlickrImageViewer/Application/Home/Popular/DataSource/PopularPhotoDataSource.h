//
//  PopularPhotoDataSource.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 02/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Photo;
@class PopularPhotoViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface PopularPhotoDataSource : NSObject <UICollectionViewDataSource,
                                              UICollectionViewDataSourcePrefetching>

//@property (nonatomic, strong) NSMutableArray<Photo *> *photos;
@property (nonatomic, strong) PopularPhotoViewModel *popularPhotoViewModel;

- (instancetype)initWithViewModel:(PopularPhotoViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
