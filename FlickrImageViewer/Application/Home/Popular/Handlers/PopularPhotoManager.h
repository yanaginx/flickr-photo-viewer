//
//  PopularPhotoManager.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 27/06/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Photo;

typedef NS_ENUM(NSUInteger, PopularPhotoManagerError) {
    PopularPhotoManagerErrorInvalidURL,
    PopularPhotoManagerErrorNetworkError,
    PopularPhotoManagerErrorNotValidData
};

@interface PopularPhotoManager : NSObject

@property (class, nonnull, readonly, strong) PopularPhotoManager *sharedPopularPhotoManager;

- (void)getPopularPhotoURLsWithPage:(NSInteger)pageNum
                  completionHandler:(void (^)(NSMutableArray<NSURL *> * _Nullable photoURLs,
                                          NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
