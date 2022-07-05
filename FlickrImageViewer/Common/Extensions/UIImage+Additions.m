//
//  UIImage+Additions.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 05/07/2022.
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

+ (UIImage *)getColoredRectImageWithColor:(CGColorRef)color
                                     size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef graphicsContext = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(graphicsContext, color);
    CGRect rectangle = CGRectMake(0, 0, size.width, size.height);
    CGContextFillRect(graphicsContext, rectangle);
    UIImage *rectangleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return rectangleImage;
}

@end
