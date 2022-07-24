//
//  MDImageCache.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/07/2022.
//
//  Copyright (c) 2009-2017 enormego.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "MDImageCache.h"

#if DEBUG
#    define CHECK_FOR_MDCACHE_PLIST() if([key isEqualToString:@"MDCache.plist"]) { \
        NSLog(@"MDCache.plist is a reserved key and can not be modified."); \
        return; }
#else
#    define CHECK_FOR_MDCACHE_PLIST() if([key isEqualToString:@"MDCache.plist"]) return;
#endif

#define kTimeoutInterval 86400
#define kMemoryCapacity 100 * 1024 * 1024

static inline NSString *cachePathForKey(NSString *directory, NSString *key) {
    key = [key stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    return [directory stringByAppendingPathComponent:key];
}

@interface MDImageCache () {
    dispatch_queue_t _cacheInfoQueue;
    dispatch_queue_t _frozenCacheInfoQueue;
    dispatch_queue_t _diskQueue;
    NSMutableDictionary *_cacheInfo;
    NSString *_directory;
    BOOL _needsSave;
    NSCache<NSString *, NSData *> *_memCache;
}
@property (nonatomic, copy) NSDictionary *frozenCacheInfo;

@end

@implementation MDImageCache

#pragma mark - Initialization

- (instancetype)init {
    NSString* cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString* oldCachesDirectory = [[[cachesDirectory stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]] stringByAppendingPathComponent:@"MDCache"] copy];

    if([[NSFileManager defaultManager] fileExistsAtPath:oldCachesDirectory]) {
        [[NSFileManager defaultManager] removeItemAtPath:oldCachesDirectory error:NULL];
    }
    
    cachesDirectory = [[[cachesDirectory stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:@"MDCache"] copy];
    return [self initWithCacheDirectory:cachesDirectory];
}

- (instancetype)initWithCacheDirectory:(NSString*)cacheDirectory {
    self = [super init];
    if (self) {
        _memCache = [[NSCache alloc] init];
        [_memCache setTotalCostLimit:kMemoryCapacity];
        
        _cacheInfoQueue = dispatch_queue_create("com.mdcache.info", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_t priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_set_target_queue(priority, _cacheInfoQueue);
        
        _frozenCacheInfoQueue = dispatch_queue_create("com.mdcache.info.frozen", DISPATCH_QUEUE_SERIAL);
        priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_set_target_queue(priority, _frozenCacheInfoQueue);
        
        _diskQueue = dispatch_queue_create("com.mdcache.disk", DISPATCH_QUEUE_CONCURRENT);
        priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_set_target_queue(priority, _diskQueue);
        
        _directory = cacheDirectory;

        _cacheInfo = [[NSDictionary dictionaryWithContentsOfFile:cachePathForKey(_directory, @"MDCache.plist")] mutableCopy];
        
        if(!_cacheInfo) {
            _cacheInfo = [[NSMutableDictionary alloc] init];
        }
        
        [[NSFileManager defaultManager] createDirectoryAtPath:_directory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
        
        NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
        NSMutableArray* removedKeys = [[NSMutableArray alloc] init];
        
        for(NSString* key in _cacheInfo) {
            if([_cacheInfo[key] timeIntervalSinceReferenceDate] <= now) {
                [[NSFileManager defaultManager] removeItemAtPath:cachePathForKey(_directory, key)
                                                           error:NULL];
                [removedKeys addObject:key];
            }
        }
        
        [_cacheInfo removeObjectsForKeys:removedKeys];
        self.frozenCacheInfo = _cacheInfo;
        [self setDefaultTimeoutInterval:kTimeoutInterval];
    }
    
    return self;
}

- (void)clearCache {
    [self->_memCache removeAllObjects];
    
    dispatch_sync(_cacheInfoQueue, ^{
        for(NSString* key in _cacheInfo) {
            [[NSFileManager defaultManager] removeItemAtPath:cachePathForKey(_directory, key)
                                                       error:NULL];
        }
        
        [_cacheInfo removeAllObjects];
        
        dispatch_sync(_frozenCacheInfoQueue, ^{
            self.frozenCacheInfo = [_cacheInfo copy];
        });

        [self setNeedsSave];
    });
}

- (void)clearDiskCache {
    dispatch_sync(_cacheInfoQueue, ^{
        for(NSString* key in _cacheInfo) {
            [[NSFileManager defaultManager] removeItemAtPath:cachePathForKey(_directory, key)
                                                       error:NULL];
        }
        
        [_cacheInfo removeAllObjects];
        
        dispatch_sync(_frozenCacheInfoQueue, ^{
            self.frozenCacheInfo = [_cacheInfo copy];
        });

        [self setNeedsSave];
    });
}

- (void)removeCacheForKey:(NSString*)key {
    [self->_memCache removeObjectForKey:key];
    
    CHECK_FOR_MDCACHE_PLIST();

    dispatch_async(_diskQueue, ^{
        [[NSFileManager defaultManager] removeItemAtPath:cachePathForKey(self->_directory, key)
                                                   error:NULL];
    });

    [self setCacheTimeoutInterval:0 forKey:key];
}

- (BOOL)hasCacheForKey:(NSString*)key {
    NSDate* date = [self dateForKey:key];
    if(date == nil) return NO;
    if([date timeIntervalSinceReferenceDate] < CFAbsoluteTimeGetCurrent()) return NO;
    
    return [[NSFileManager defaultManager] fileExistsAtPath:cachePathForKey(_directory, key)];
}

- (NSDate*)dateForKey:(NSString*)key {
    __block NSDate* date = nil;

    dispatch_sync(_frozenCacheInfoQueue, ^{
        date = (self.frozenCacheInfo)[key];
    });

    return date;
}

- (NSArray*)allKeys {
    __block NSArray* keys = nil;

    dispatch_sync(_frozenCacheInfoQueue, ^{
        keys = [self.frozenCacheInfo allKeys];
    });

    return keys;
}

- (void)setCacheTimeoutInterval:(NSTimeInterval)timeoutInterval forKey:(NSString*)key {
    NSDate* date = timeoutInterval > 0 ? [NSDate dateWithTimeIntervalSinceNow:timeoutInterval] : nil;
    
    // Temporarily store in the frozen state for quick reads
    dispatch_sync(_frozenCacheInfoQueue, ^{
        NSMutableDictionary* info = [self.frozenCacheInfo mutableCopy];
        
        if(date) {
            info[key] = date;
        } else {
            [info removeObjectForKey:key];
        }
        
        self.frozenCacheInfo = info;
    });
    
    // Save the final copy (this may be blocked by other operations)
    dispatch_async(_cacheInfoQueue, ^{
        if(date) {
            self->_cacheInfo[key] = date;
        } else {
            [self->_cacheInfo removeObjectForKey:key];
        }
        
        dispatch_sync(self->_frozenCacheInfoQueue, ^{
            self.frozenCacheInfo = [self->_cacheInfo copy];
        });

        [self setNeedsSave];
    });
}

#pragma mark -
#pragma mark Copy file methods

- (void)copyFilePath:(NSString *)filePath
               asKey:(NSString *)key {
    [self copyFilePath:filePath
                 asKey:key
   withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)copyFilePath:(NSString *)filePath
               asKey:(NSString *)key
 withTimeoutInterval:(NSTimeInterval)timeoutInterval {
    dispatch_async(_diskQueue, ^{
        [[NSFileManager defaultManager] copyItemAtPath:filePath
                                                toPath:cachePathForKey(self->_directory, key)
                                                 error:NULL];
    });
    
    [self setCacheTimeoutInterval:timeoutInterval
                           forKey:key];
}

#pragma mark -
#pragma mark Data methods

- (void)setData:(NSData *)data
         forKey:(NSString *)key {
    [self   setData:data
             forKey:key
withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)    setData:(NSData *)data
             forKey:(NSString *)key
withTimeoutInterval:(NSTimeInterval)timeoutInterval {
    CHECK_FOR_MDCACHE_PLIST();
    NSString* cachePath = cachePathForKey(_directory, key);
    dispatch_async(_diskQueue, ^{
        [data writeToFile:cachePath atomically:YES];
    });
    
    [self setCacheTimeoutInterval:timeoutInterval forKey:key];
}

- (void)setNeedsSave {
    dispatch_async(_cacheInfoQueue, ^{
        if(self->_needsSave) return;
        self->_needsSave = YES;
        
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, self->_cacheInfoQueue, ^(void){
            if(!self->_needsSave) return;
            [self->_cacheInfo writeToFile:cachePathForKey(self->_directory, @"MDCache.plist")
                               atomically:YES];
            self->_needsSave = NO;
        });
    });
}

- (NSData *)dataForKey:(NSString *)key {
    if([self hasCacheForKey:key]) {
        return [NSData dataWithContentsOfFile:cachePathForKey(_directory, key)
                                      options:0
                                        error:NULL];
    } else {
        return nil;
    }
}

#pragma mark -
#pragma mark - Image methods
- (UIImage *)imageForKey:(NSString *)key {
    // Fetch from the mem cache first
    NSData *memImageData = [self->_memCache objectForKey:key];
    if (memImageData != nil) {
        UIImage *memImage = [UIImage imageWithData:memImageData];
        return memImage;
    }
    
    // If not then check the disk
    UIImage *diskImage = nil;
//    @try {
        NSData *diskImageData = [self dataForKey:key];
        if (diskImageData != nil) {
            diskImage = [UIImage imageWithData:diskImageData];
            // put the data in the mem cache
            [self->_memCache setObject:diskImageData
                                forKey:key];
        }
//    } @catch (NSException* e) {
//        // Surpress any unarchiving exceptions and continue with nil
//    }
    return diskImage;
}

- (void)setImage:(UIImage *)anImage
          forKey:(NSString *)key {
    [self setImage:anImage
            forKey:key
   timeoutInterval:self.defaultTimeoutInterval];
}

- (void)setImage:(UIImage *)anImage
          forKey:(NSString *)key
 timeoutInterval:(NSTimeInterval)timeoutInterval {
    // Gonna use JPEG instead
    NSData *imageData = UIImageJPEGRepresentation(anImage, 1.0);
    // Put in the mem cache first
    [self->_memCache setObject:imageData
                        forKey:key];
//    @try {
//        // Using NSKeyedArchiver preserves all information such as scale, orientation, and the proper image format instead of saving everything as pngs
////        [self setData:[NSKeyedArchiver archivedDataWithRootObject:anImage]
        [self setData:imageData
               forKey:key
  withTimeoutInterval:timeoutInterval];
//    } @catch (NSException* e) {
//        // Something went wrong, but we'll fail silently.
//    }
}


@end
