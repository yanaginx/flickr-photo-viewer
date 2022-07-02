//
//  NSUserDefaults+Additions.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 02/07/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSUserDefaults (Additions)

- (void)saveUserObject:(id<NSCoding>)object
                   key:(NSString *)key;

- (id<NSCoding>)loadUserObjectWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END

