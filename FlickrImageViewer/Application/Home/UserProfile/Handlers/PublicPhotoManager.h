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

@property (class, nonnull, readonly, strong) PublicPhotoManager *sharedPublicPhotoManager;

- (void)getPublicPhotoURLsWithPage:(NSInteger)pageNum
                 completionHandler:(void (^)(NSMutableArray<Photo *> * _Nullable photos,
                                             NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END

