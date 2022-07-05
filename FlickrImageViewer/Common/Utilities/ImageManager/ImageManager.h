//
//  ImageManager.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 05/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ImageManagerError) {
    ImageManagerErrorInvalidURL,
    ImageManagerErrorNetworkError,
    ImageManagerErrorNotValidImage
};

@interface ImageManager : NSObject

+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedImageManager instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedImageManager instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedImageManager instead")));
- (instancetype)copy __attribute__((unavailable("copy not available, call sharedImageManager instead")));

@property (class, nonnull, readonly, strong) ImageManager *sharedImageManager;

- (NSURLSessionTask * _Nullable)fetchImageWithURL:(NSURL *)url completion:(void (^)(UIImage * _Nullable image, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
