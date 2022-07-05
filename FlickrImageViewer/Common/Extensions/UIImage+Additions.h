//
//  UIImage+Additions.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 05/07/2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Additions)

+ (UIImage *)getColoredRectImageWithColor:(CGColorRef) color
                                     size:(CGSize) size;

@end

NS_ASSUME_NONNULL_END
