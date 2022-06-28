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

@property (nonatomic, strong) NSCache<NSUUID *, UIImage *> *cache;

- (void)fetchAsyncForIdentifier:(NSUUID *)identifier
                       imageURL:(NSURL *)imageURL
                     completion:(nullable handlerBlock)completion;

- (UIImage *)fetchedDataForIdentifier:(NSUUID *)identifier;

- (void)cancelFetchForIdentifier:(NSUUID *)identifier;

@end

NS_ASSUME_NONNULL_END
