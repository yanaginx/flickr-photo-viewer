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

@property (nonatomic, strong) NSCache<NSString *, UIImage *> *cache;

- (void)fetchAsyncForIdentifier:(NSString *)identifier
                       imageURL:(NSURL *)imageURL
                     completion:(nullable handlerBlock)completion;

- (UIImage *)fetchedDataForIdentifier:(NSString *)identifier;

- (void)cancelFetchForIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
