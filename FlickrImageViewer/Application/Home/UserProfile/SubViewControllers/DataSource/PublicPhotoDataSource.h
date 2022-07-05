//
//  PublicPhotoDataSource.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 02/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Photo;

NS_ASSUME_NONNULL_BEGIN

@interface PublicPhotoDataSource : NSObject <UICollectionViewDataSource,
                                             UICollectionViewDataSourcePrefetching>

@property (nonatomic, strong) NSMutableArray<Photo *> *photos;

@end

NS_ASSUME_NONNULL_END
