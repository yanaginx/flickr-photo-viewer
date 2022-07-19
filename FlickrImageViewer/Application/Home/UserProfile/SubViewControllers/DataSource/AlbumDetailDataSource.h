//
//  AlbumDetailDataSource.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 04/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Photo;

NS_ASSUME_NONNULL_BEGIN

@interface AlbumDetailDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray<Photo *> *photos;

@end

NS_ASSUME_NONNULL_END
