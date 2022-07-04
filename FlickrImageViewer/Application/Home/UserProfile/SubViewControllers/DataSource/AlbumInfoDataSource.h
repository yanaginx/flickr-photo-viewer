//
//  AlbumInfoDataSource.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 04/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AlbumInfo;

NS_ASSUME_NONNULL_BEGIN

@interface AlbumInfoDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray<AlbumInfo *> *albumInfos;

@end

NS_ASSUME_NONNULL_END
