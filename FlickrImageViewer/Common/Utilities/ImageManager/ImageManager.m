//
//  ImageManager.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 05/07/2022.
//

#import "ImageManager.h"

@interface ImageManager ()
@property (nonatomic, strong) NSCache<NSString *, UIImage *> *imageCache;
@end

@implementation ImageManager

+ (instancetype)sharedImageManager {
    static dispatch_once_t onceToken;
    static ImageManager *shared;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] initPrivate];
    });
    return shared;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _imageCache = [[NSCache alloc] init];
        // Setting cache threshold
        [_imageCache setCountLimit:50];
    }
    return self;
}

- (NSURLSessionTask *)fetchImageWithURL:(NSURL *)url completion:(void (^)(UIImage *image, NSError *error))completion {
    UIImage *cachedImage = [self.imageCache objectForKey:url.absoluteString];
    if (cachedImage) {
        completion(cachedImage, nil);
        return nil;
    }

    if (!url) {
        NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:ImageManagerErrorInvalidURL userInfo:nil];
        completion(nil, error);
        return nil;
    }

    NSURLSessionTask *task = [NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }

        if (!data) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:ImageManagerErrorNetworkError userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
        }

        UIImage *image = [UIImage imageWithData:data];
        if (!image) {
            NSDictionary *userInfo = @{
                @"data": data,
                @"response": response ? response : [NSNull null]
            };
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:ImageManagerErrorNotValidImage userInfo:userInfo];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
        }

        [self.imageCache setObject:image forKey:url.absoluteString];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(image, nil);
        });
    }];

    [task resume];

    return task;
}

@end
