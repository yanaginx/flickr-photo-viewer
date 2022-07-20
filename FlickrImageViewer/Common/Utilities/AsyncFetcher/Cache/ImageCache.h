//
//  ImageCache.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 19/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonHMAC.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageCache : NSCache

// Check both mem cache and disk cache
// When mem cache miss -> fetch from disk cache then load to mem cache
// When disk cache miss -> return nil
- (UIImage * _Nullable)imageForURL:(NSURL *)url;

/**
 Set to mem cache then disk cache the image
 
 - Parameter
    - image: The `UIImage` to put in the cache.
    - url: The `NSURL` identifying the image.
 */
- (void)setToCacheImage:(UIImage *)image
                 forURL:(NSURL *)url;

// Remove all objects in cache
- (void)clearCache;

// Remove object for url
- (void)removeImageForURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
