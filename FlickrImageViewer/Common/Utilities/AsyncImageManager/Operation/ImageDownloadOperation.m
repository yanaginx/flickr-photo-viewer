//
//  ImageDownloadOperation.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 19/07/2022.
//

#import "ImageDownloadOperation.h"
#import "../../../Constants/Constants.h"

@interface ImageDownloadOperation ()

@property(readwrite) BOOL executing;
@property(readwrite) BOOL finished;

@end

@implementation ImageDownloadOperation

#pragma mark - Initialization
- (instancetype)initWithIdentifier:(NSString *)identifier
                          imageURL:(NSURL *)imageURL {
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.imageURL = imageURL;
    }
    return self;
}

- (void)start {
    if (self.cancelled) {
        self.finished = YES;
        return;
    }
    NSLog(@"Starting %@", self);
    self.executing = YES;
    [self _fetchImageWithURL:self.imageURL
                  completion:^(UIImage *image,
                               NSError *error) {
        self.fetchedData = image;
        self.error = error;
        
        NSLog(@"Finished %@", self);
        self.executing = NO;
        self.finished = YES;
    }];
    
}

// The rest of this is boilerplate.

- (BOOL)isAsynchronous {
    return YES;
}

@synthesize executing = _executing;

- (BOOL)isExecuting {
    @synchronized(self) {
        return _executing;
    }
}

- (void)setExecuting:(BOOL)executing {
    @synchronized(self) {
        if (executing != _executing) {
            [self willChangeValueForKey:@"isExecuting"];
            _executing = executing;
            [self didChangeValueForKey:@"isExecuting"];
        }
    }
}

@synthesize finished = _finished;

- (BOOL)isFinished {
    @synchronized(self) {
        return _finished;
    }
}

- (void)setFinished:(BOOL)finished {
    @synchronized(self) {
        if (finished != _finished) {
            [self willChangeValueForKey:@"isFinished"];
            _finished = finished;
            [self didChangeValueForKey:@"isFinished"];
        }
    }
}


#pragma mark - Private methods
- (void)_fetchImageWithURL:(NSURL *)url
                completion:(void (^)(UIImage *image,
                                     NSError *error))completion {
    if (!url) {
        NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                             code:kNetworkError
                                         userInfo:nil];
        completion(nil, error);
        return;
    }

    NSURLSessionTask *task = [NSURLSession.sharedSession dataTaskWithURL:url
                                                       completionHandler:^(NSData * _Nullable data,
                                                                           NSURLResponse * _Nullable response,
                                                                           NSError * _Nullable error) {
        if (error) {
            completion(nil, error);
            return;
        }

        if (!data) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kServerError
                                             userInfo:nil];
            completion(nil, error);
        }

        UIImage *image = [UIImage imageWithData:data];
        if (!image) {
            NSDictionary *userInfo = @{
                @"data": data,
                @"response": response ? response : [NSNull null]
            };
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kNoDataError
                                             userInfo:userInfo];
            completion(nil, error);
        }
        completion(image, nil);
    }];
    [task resume];
}



@end
