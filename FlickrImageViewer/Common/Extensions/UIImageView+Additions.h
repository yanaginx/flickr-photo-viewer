//
//  UIImageView+Additions.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 05/07/2022.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (Additions)

- (void)setImageUsingURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
