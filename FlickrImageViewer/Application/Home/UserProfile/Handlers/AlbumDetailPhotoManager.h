//
//  AlbumDetailPhotoManager.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 04/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Photo;

NS_ASSUME_NONNULL_BEGIN

@interface AlbumDetailPhotoManager : NSObject

- (void)getAlbumDetailPhotosForAlbumID:(NSString *)albumID
                                  page:(NSInteger)pageNum
                     completionHandler:(void (^)(NSMutableArray<Photo *> * _Nullable photos,
                                                 NSError * _Nullable error))completion;

- (BOOL)isConnected;

@end

NS_ASSUME_NONNULL_END
