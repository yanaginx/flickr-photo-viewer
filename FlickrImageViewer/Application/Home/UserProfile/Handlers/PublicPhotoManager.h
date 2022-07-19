//
//  PublicPhotoManager.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 01/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class Photo;

@interface PublicPhotoManager : NSObject

- (void)getPublicPhotoURLsWithPage:(NSInteger)pageNum
                 completionHandler:(void (^)(NSMutableArray<Photo *> * _Nullable photos,
                                             NSError * _Nullable error))completion;

- (BOOL)isConnected;

@end

NS_ASSUME_NONNULL_END

