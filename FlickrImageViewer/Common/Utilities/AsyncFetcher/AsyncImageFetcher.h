//
//  AsyncFetcher.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 28/06/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef void (^handlerBlock)(UIImage * _Nullable);

@interface AsyncImageFetcher : NSObject

+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedImageManager instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedImageManager instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedImageManager instead")));
- (instancetype)copy __attribute__((unavailable("copy not available, call sharedImageManager instead")));

@property (class, nonnull, readonly, strong) AsyncImageFetcher *sharedImageFetcher;

@property (nonatomic, strong) NSCache<NSString *, UIImage *> *cache;

- (void)fetchAsyncForIdentifier:(NSString *)identifier
                       imageURL:(NSURL *)imageURL
                     completion:(nullable handlerBlock)completion;

- (UIImage *)fetchedDataForIdentifier:(NSString *)identifier;

- (void)cancelFetchForIdentifier:(NSString *)identifier;

- (void)clearDiskCache;

@end

NS_ASSUME_NONNULL_END
