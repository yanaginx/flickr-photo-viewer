//
//  AsyncImageFetcherOperation.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 28/06/2022.
//

#import "AsyncImageFetcherOperation.h"

@interface AsyncImageFetcherOperation ()

@end

@implementation AsyncImageFetcherOperation

#pragma mark - Initialization
- (instancetype)initWithIdentifier:(NSUUID *)identifier
                          imageURL:(NSURL *)imageURL {
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.imageURL = imageURL;
    }
    return self;
}

#pragma mark - Operation override
- (void)main {
    UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:self.imageURL]];
    if (!self.isCancelled) {
        if (image) {
            self.fetchedData = image;
        }
        else {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:1
                                             userInfo:nil];
            self.error = error;
        }
    }
}

#pragma mark - Operations
- (void)downloadImageFromURL {
    //    NSURLSessionTask *task = [NSURLSession.sharedSession dataTaskWithURL:self.imageURL
//                                                       completionHandler:^(NSData * _Nullable data,
//                                                                           NSURLResponse * _Nullable response,
//                                                                           NSError * _Nullable error) {
//        UIImage *image = [UIImage imageWithData:data];
//        self.fetchedData = image;
//        self.error = error;
//    }];
//    [task resume];
}

@end
