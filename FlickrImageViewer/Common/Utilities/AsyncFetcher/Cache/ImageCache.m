//
//  ImageCache.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 19/07/2022.
//

#import "ImageCache.h"

@interface ImageCache ()

@property (nonatomic, strong) NSOperationQueue *diskOperationQueue;

@end

@implementation ImageCache


#pragma mark - Initialization
- (instancetype)init {
    self = [super init];
    if (self) {
        self.diskOperationQueue = [[NSOperationQueue alloc] init];
//        [[NSFileManager defaultManager] createDirectoryAtPath:[self _imageCachePath]
//                                  withIntermediateDirectories:YES
//                                                   attributes:nil
//                                                        error:nil];
    }
    return self;
}

#pragma mark - Public methods
- (UIImage *)imageForURL:(NSURL *)url {
    return [self _cachedImageForURL:url];
}

- (void)setToCacheImage:(UIImage *)image
                 forURL:(NSURL *)url {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self _setToMemCacheImage:image
                           forURL:url];
        [self _setToDiskCacheImage:image
                            forURL:url];
    });
}

- (void)removeImageForURL:(NSURL *)url {
    [self _removeImageFromMemCacheForURL:url];
    [self _removeImageFromDiskCacheForURL:url];
}

- (void)clearCache {
    // clear the mem cache
    [super removeAllObjects];
    
    // clear the disk cache
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSError *error = nil;
        NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:[self _imageCachePath]
                                                                  error:&error];
        if (error == nil) {
            for (NSString *path in directoryContents) {
                NSString *fullPath = [[self _imageCachePath] stringByAppendingPathComponent:path];
                BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath
                                                         error:&error];
                if (!removeSuccess) {
                    //Error Occured
                }
            }
        } else {
            //Error Occured
        }
    });
}


#pragma mark - Private methods

- (UIImage *)_cachedImageForURL:(NSURL *)url {
    NSString *key = [self _keyForURL:url];
    id objectToReturn = [super objectForKey:key];
    if (objectToReturn) {
        return (UIImage *)objectToReturn;
    } else {
        UIImage *image = [self _imageFromDiskForURL:url];
        // Set the image to mem cache
        if (image) {
            [self _setToMemCacheImage:image
                               forURL:url];
        }
        return image;
    }
    return nil;
}

// Set image to mem cache
- (void)_setToMemCacheImage:(UIImage *)image
                     forURL:(NSURL *)url {
    NSString *key = [self _keyForURL:url];
    [self _setImage:image
             forKey:key];
}

- (void)_removeImageFromMemCacheForURL:(NSURL *)url {
    NSString *key = [self _keyForURL:url];
    [self _removeImageForKey:key];
}

// Set image to disk cache
- (void)_setToDiskCacheImage:(UIImage *)image
                      forURL:(NSURL *)url {
    NSString *key = [self _keyForURL:url];
    NSString *cachePath = [self _cachePathForKey:key];
    NSMethodSignature *methodSignature =  [self methodSignatureForSelector:@selector(_writeData:toPath:)];
    NSInvocation *writeInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    [writeInvocation setTarget:self];
    [writeInvocation setArgument:&imageData atIndex:2];
    [writeInvocation setArgument:&cachePath atIndex:3];
    
    [self _performDiskWriteOperation:writeInvocation];
}

- (void)_removeImageFromDiskCacheForURL:(NSURL *)url {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSString *key = [self _keyForURL:url];
        NSString *cachePath = [self _cachePathForKey:key];
        NSError *error = nil;
        BOOL removeSuccess = [fileMgr removeItemAtPath:cachePath error:&error];
        if (!removeSuccess) {
            //Error Occured
        }
    });
}

- (void)_writeData:(NSData *)data
            toPath:(NSString *)path {
    [data writeToFile:path atomically:YES];
}

- (void)_performDiskWriteOperation:(NSInvocation *)invocation {
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithInvocation:invocation];
    
    [self.diskOperationQueue addOperation:operation];
}

- (NSString *)_keyForURL:(NSURL *)url {
    return url.absoluteString;
}

- (NSString *)_imageCachePath {
    NSURL *cacheURL = [[[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory
                                                              inDomain:NSUserDomainMask
                                                     appropriateForURL:nil
                                                                create:YES
                                                                 error:nil]
                       URLByAppendingPathComponent:@"vn.vng.duongvc.flickrz"];
    return cacheURL.path;
}

- (UIImage *)_imageFromDiskForURL:(NSURL *)url {
    NSString *key = [self _keyForURL:url];
    return [self _imageFromDiskForKey:key];
}

- (UIImage *)_imageFromDiskForKey:(NSString *)key {
    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:[self _cachePathForKey:key]
                                                                      options:0
                                                                        error:NULL]];
    return image;
}

- (void)_setImage:(UIImage *)image
           forKey:(NSString *)key {
    if (image) {
        [super setObject:image
                  forKey:key];
    }
}

- (void)_removeImageForKey:(NSString *)key {
    [self removeObjectForKey:key];
}

- (NSString *)_cachePathForKey:(NSString *)key {
    NSString *shaString = [self _SHA1FromString:key];
    NSString *fileName = [NSString stringWithFormat:@"ImageCache-%@", shaString];
    return [[self _imageCachePath] stringByAppendingPathComponent:fileName];
}

#pragma mark - Hash methods
- (NSString *)_SHA1FromString:(NSString *)string {
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    NSData *stringBytes = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    if (CC_SHA1([stringBytes bytes], (CC_LONG)[stringBytes length], digest)) {
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x", digest[i]];
        }
        return output;
    }
    return nil;
}

@end
