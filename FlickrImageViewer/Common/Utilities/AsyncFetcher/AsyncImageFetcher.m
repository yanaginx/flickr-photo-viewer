//
//  AsyncImageFetcher.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 28/06/2022.
//

#import "AsyncImageFetcher.h"
#import "../Defer/Defer.h"
#import "../Scope/Scope.h"
#import "Operation/AsyncImageFetcherOperation.h"

@interface AsyncImageFetcher ()

@property (nonatomic, strong) NSOperationQueue *serialAccessQueue;
@property (nonatomic, strong) NSOperationQueue *fetchQueue;
@property (nonatomic, strong) NSMutableDictionary<NSUUID *, NSMutableArray<handlerBlock> *> *completionHandlers;

@end

@implementation AsyncImageFetcher

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.serialAccessQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

#pragma mark - Object fetching
/**
 Asynchronously fetches data for a specified `UUID`.
 
 - Parameters:
     - identifier: The `UUID` to fetch data for.
     - imageURL: The `NSURL` of the image.
     - completion: An optional called when the data has been fetched.
*/

- (void)fetchAsyncForIdentifier:(NSUUID *)identifier
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
- (UIImage *)fetchedDataForIdentifier:(NSUUID *)identifier {
    return [self.cache objectForKey:identifier];
}

/**
 Cancels any enqueued asychronous fetches for a specified `UUID`. Completion
 handlers are not called if a fetch is canceled.
 
 - Parameter identifier: The `UUID` to cancel fetches for.
 */
- (void)cancelFetchForIdentifier:(NSUUID *)identifier {
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
- (void)fetchDataForIdentifier:(NSUUID *)identifier
                      imageURL:(NSURL *)imageURL {
    // If a request has already been made for the object, do nothing more.
    if ([self operationForIdentifier:identifier] != nil) return;
    
    UIImage *data = [self fetchedDataForIdentifier:identifier];
    if (data) {
        // The object has been cached; call the completion handler with that object
        [self invokeCompletionHandlersForIdentifier:identifier
                                    withFetchedData:data];
    } else {
        // Enqueue a request for the object
        AsyncImageFetcherOperation *operation = [[AsyncImageFetcherOperation alloc] initWithIdentifier:identifier
                                                                                              imageURL:imageURL];
        
        // Set the operation's completion block to cache the fetched object and call the associated completion blocks
        @weakify(operation)
        operation.completionBlock = ^{
            @strongify(operation)
            UIImage *fetchedData = operation.fetchedData;
            if (fetchedData == nil) return;
            [self.cache setObject:fetchedData forKey:identifier];
            
            [self.serialAccessQueue addOperationWithBlock:^{
                [self invokeCompletionHandlersForIdentifier:identifier withFetchedData:fetchedData];
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
- (AsyncImageFetcherOperation *)operationForIdentifier:(NSUUID *)identifier {
    for (AsyncImageFetcherOperation *operation in self.fetchQueue.operations) {
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
- (void)invokeCompletionHandlersForIdentifier:(NSUUID *)identifier
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

- (NSMutableDictionary<NSUUID *, NSMutableArray<void (^)(UIImage *)> *> *)completionHandlers {
    if (_completionHandlers) return _completionHandlers;
    _completionHandlers = [NSMutableDictionary dictionary];
    return _completionHandlers;
}

- (NSCache<NSUUID *, UIImage *> *)cache {
    if (_cache) return _cache;
    _cache = [[NSCache alloc] init];
    return _cache;
}

@end
