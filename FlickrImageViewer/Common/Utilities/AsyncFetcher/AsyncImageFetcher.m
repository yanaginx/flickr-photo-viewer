//
//  AsyncImageFetcher.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 28/06/2022.
//

#import "AsyncImageFetcher.h"
#import "../Defer/Defer.h"
#import "../Scope/Scope.h"
#import "Operation/ImageDownloadOperation.h"
#import "Cache/ImageURLCache.h"
#import "Cache/ImageCache.h"
#import "Cache/MDImageCache.h"

#define kMaxAsyncOperations 4
#define kMemoryCapacity 100 * 1024 * 1024
#define kDiskCapacity 200 * 1024 * 1024

@interface AsyncImageFetcher ()

@property (nonatomic, strong) NSOperationQueue *serialAccessQueue;
@property (nonatomic, strong) NSOperationQueue *fetchQueue;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<handlerBlock> *> *completionHandlers;
@property (nonatomic, strong) NSURLSession *downloadSession;
@property (nonatomic, strong) ImageURLCache *imageURLCache;
@property (nonatomic, strong) ImageCache *imageCache;
@property (nonatomic, strong) MDImageCache *mdImageCache;

@end

@implementation AsyncImageFetcher

#pragma mark - Initialization

+ (instancetype)sharedImageFetcher {
    static dispatch_once_t onceToken;
    static AsyncImageFetcher *shared;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] initPrivate];
    });
    return shared;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        self.serialAccessQueue.maxConcurrentOperationCount = 1;
        self.fetchQueue.maxConcurrentOperationCount = kMaxAsyncOperations;
    }
    return self;
}

//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        }
//    return self;
//}

#pragma mark - Object fetching
/**
 Asynchronously fetches data for a specified `UUID`.
 
 - Parameters:
     - identifier: The `UUID` to fetch data for.
     - imageURL: The `NSURL` of the image.
     - completion: An optional called when the data has been fetched.
*/

- (void)fetchAsyncForIdentifier:(NSString *)identifier
                       imageURL:(nonnull NSURL *)imageURL
                     completion:(nullable void (^)(UIImage * _Nullable))completion {
    [self.serialAccessQueue addOperationWithBlock:^{
        if (completion != nil) {
            NSMutableArray *handlers = [self.completionHandlers objectForKey:identifier];
            if (handlers == nil) {
                handlers = [NSMutableArray array];
            }
            [handlers addObject:completion];
            [self.completionHandlers setObject:handlers
                                        forKey:identifier];
        }
        [self fetchDataForIdentifier:identifier
                            imageURL:imageURL];
    }];
}

/**
 Returns the previously fetched data for a specified `UUID`.
 
 - Parameter identifier: The `UUID` of the object to return.
 - Returns: The 'UIImage ' that has previously been fetched or nil.
 */
- (UIImage *)fetchedDataForIdentifier:(NSString *)identifier {
//    return [self.cache objectForKey:identifier];
    return [self.mdImageCache imageForKey:identifier];
}

- (UIImage *)fetchedDiskDataForIdentifier:(NSString *)identifier {
    NSURLRequest *requestWithURL = [[NSURLRequest alloc]
                                    initWithURL:[NSURL URLWithString:identifier]];
    NSCachedURLResponse *cachedResponse = [self.imageURLCache cachedResponseForRequest:requestWithURL];
    if (cachedResponse.data) {
        UIImage *image = [UIImage imageWithData:cachedResponse.data];
//        NSLog(@"[DEBUG] %s: FOUND: %@",
//              __func__,
//              image);
        return image;
    }
    return nil;
}

/**
 Cancels any enqueued asychronous fetches for a specified `UUID`. Completion
 handlers are not called if a fetch is canceled.
 
 - Parameter identifier: The `UUID` to cancel fetches for.
 */
- (void)cancelFetchForIdentifier:(NSString *)identifier {
    [self.serialAccessQueue addOperationWithBlock:^{
        [self.fetchQueue setSuspended:YES];
        pspdf_defer {
            [self.fetchQueue setSuspended:NO];
        };
        // cancel the operation here
        [[self operationForIdentifier:identifier] cancel];
        [self.completionHandlers removeObjectForKey:identifier];
    }];
}

#pragma mark - Convinience
/**
 Begins fetching data for the provided `identifier` invoking the associated
 completion handler when complete.
 
 - Parameter identifier: The `UUID` to fetch data for.
 */
- (void)fetchDataForIdentifier:(NSString *)identifier
                      imageURL:(NSURL *)imageURL {
    // If a request has already been made for the object, do nothing more.
    if ([self operationForIdentifier:identifier] != nil) return;
    
    UIImage *cachedImage = [self fetchedDataForIdentifier:identifier];
    if (cachedImage) {
        [self invokeCompletionHandlersForIdentifier:identifier
                                    withFetchedData:cachedImage];
    } else {
        // Enqueue a request for the object
        ImageDownloadOperation *operation = [[ImageDownloadOperation alloc]
                                             initWithIdentifier:identifier
                                             imageURL:imageURL
                                             URLSession:self.downloadSession
                                             imageURLCache:self.imageURLCache];

        // Set the operation's completion block to cache the fetched object and call the associated completion blocks
        @weakify(operation)
        operation.completionBlock = ^{
            @strongify(operation)
            UIImage *fetchedData = operation.fetchedData;
            NSError *error = operation.error;
            if (error) NSLog(@"[DEBUG] %s : error : %@", __func__, error);
            if (fetchedData == nil) return;
            [self.mdImageCache setImage:fetchedData
                                 forKey:imageURL.absoluteString];
            [self.serialAccessQueue addOperationWithBlock:^{
                [self invokeCompletionHandlersForIdentifier:identifier
                                            withFetchedData:fetchedData];
            }];
        };
        [self.fetchQueue addOperation:operation];
    }
}

/**
 Returns any enqueued `ObjectFetcherOperation` for a specified `UUID`.
 
 - Parameter identifier: The `UUID` of the operation to return.
 - Returns: The enqueued `ObjectFetcherOperation` or nil.
 */
- (ImageDownloadOperation *)operationForIdentifier:(NSString *)identifier {
    for (ImageDownloadOperation *operation in self.fetchQueue.operations) {
        if (!operation.isCancelled && operation.identifier == identifier) {
            return operation;
        }
    }
    return nil;
}

/**
 Invokes any completion handlers for a specified `UUID`. Once called,
 the stored array of completion handlers for the `UUID` is cleared.
 
 - Parameters:
 - identifier: The `UUID` of the completion handlers to call.
 - object: The fetched object to pass when calling a completion handler.
 */
- (void)invokeCompletionHandlersForIdentifier:(NSString *)identifier
                              withFetchedData:(UIImage *)fetchedData {
    NSMutableArray *completionHandlers = [self.completionHandlers objectForKey:identifier];
    if (completionHandlers == nil) {
        completionHandlers = [NSMutableArray array];
    }
    [self.completionHandlers removeObjectForKey:identifier];
    for (handlerBlock completionHandler in completionHandlers) {
        completionHandler(fetchedData);
    }
}


#pragma mark - Custom Accessors
- (NSOperationQueue *)serialAccessQueue {
    if (_serialAccessQueue) return _serialAccessQueue;
    _serialAccessQueue = [[NSOperationQueue alloc] init];
    return _serialAccessQueue;
}

- (NSOperationQueue *)fetchQueue {
    if (_fetchQueue) return _fetchQueue;
    _fetchQueue = [[NSOperationQueue alloc] init];
    return _fetchQueue;
}

- (NSMutableDictionary<NSString *, NSMutableArray<void (^)(UIImage *)> *> *)completionHandlers {
    if (_completionHandlers) return _completionHandlers;
    _completionHandlers = [NSMutableDictionary dictionary];
    return _completionHandlers;
}

- (NSCache<NSString *, UIImage *> *)cache {
    if (_cache) return _cache;
    _cache = [[NSCache alloc] init];
    [_cache setTotalCostLimit:kMemoryCapacity];
    return _cache;
}

- (NSURLSession *)downloadSession {
    if (_downloadSession) return _downloadSession;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.allowsCellularAccess = YES;
    configuration.timeoutIntervalForRequest = 60.0;
    
    _downloadSession = [NSURLSession sessionWithConfiguration:configuration];
    
    return _downloadSession;
}

- (ImageURLCache *)imageURLCache {
    if (_imageURLCache) return _imageURLCache;
    
    NSUInteger memoryCapacity = kMemoryCapacity;
    NSUInteger diskCapacity = kDiskCapacity;
    NSURL *cacheURL = [[[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory
                                                              inDomain:NSUserDomainMask
                                                     appropriateForURL:nil
                                                                create:YES
                                                                 error:nil]
                       URLByAppendingPathComponent:@"DOWNLOAD_CACHE"];
    _imageURLCache =  [[ImageURLCache alloc] initWithMemoryCapacity:memoryCapacity
                                                       diskCapacity:diskCapacity
                                                           diskPath:[cacheURL path]];
    return _imageURLCache;
}

- (ImageCache *)imageCache {
    if (_imageCache) return _imageCache;
    
    _imageCache = [[ImageCache alloc] init];
    [_imageCache setTotalCostLimit:kMemoryCapacity];
    return _imageCache;
}

- (MDImageCache *)mdImageCache {
    if (_mdImageCache) return _mdImageCache;
    
    _mdImageCache = [[MDImageCache alloc] init];
    return _mdImageCache;
}

@end
