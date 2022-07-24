//
//  MDImageCache.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDImageCache : NSObject

//- (instancetype)initWithCacheDirectory:(NSString *)cacheDirectory;
- (void)clearCache;
- (void)clearDiskCache;
- (void)removeCacheForKey:(NSString *)key;
- (BOOL)hasCacheForKey:(NSString *)key;

- (UIImage * _Nullable)imageForKey:(NSString *)key;
- (void)setImage:(UIImage *)anImage
          forKey:(NSString *)key;
- (void)setImage:(UIImage *)anImage
          forKey:(NSString *)key
 timeoutInterval:(NSTimeInterval)timeoutInterval;

@property (nonatomic) NSTimeInterval defaultTimeoutInterval; 

@end

NS_ASSUME_NONNULL_END
