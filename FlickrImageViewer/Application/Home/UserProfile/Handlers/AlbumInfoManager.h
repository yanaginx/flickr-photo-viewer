//
//  AlbumInfoManager.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 04/07/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AlbumInfo;

@interface AlbumInfoManager : NSObject

- (void)getUserAlbumInfosWithPage:(NSInteger)pageNum
                completionHandler:(void (^)(NSMutableArray<AlbumInfo *> * _Nullable albumInfos,
                                            NSError * _Nullable error))completion;

- (BOOL)isConnected;

@end

NS_ASSUME_NONNULL_END
