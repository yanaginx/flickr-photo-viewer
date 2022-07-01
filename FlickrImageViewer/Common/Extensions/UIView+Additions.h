//
//  UIView+Additions.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Additions)

- (void)setAnchorTop:(NSLayoutYAxisAnchor *)top
                left:(NSLayoutXAxisAnchor *)left
              bottom:(NSLayoutYAxisAnchor *)bottom
               right:(NSLayoutXAxisAnchor *)right
          paddingTop:(CGFloat)paddingTop
         paddingLeft:(CGFloat)paddingLeft
       paddingBottom:(CGFloat)paddingBottom
        paddingRight:(CGFloat)paddingRight
               width:(CGFloat)width
              height:(CGFloat)height;

- (void)setAnchorTop:(NSLayoutYAxisAnchor *)top
          paddingTop:(CGFloat)paddingTop;
- (void)setAnchorLeft:(NSLayoutXAxisAnchor *)left
          paddingLeft:(CGFloat)paddingLeft;
- (void)setAnchorBottom:(NSLayoutYAxisAnchor *)bottom
          paddingBottom:(CGFloat)paddingBottom;
- (void)setAnchorRight:(NSLayoutXAxisAnchor *)right
          paddingRight:(CGFloat)paddingRight;
- (void)setAnchorWidth:(CGFloat)width;
- (void)setAnchorHeight:(CGFloat)height;

- (void)setAnchorCenterX:(NSLayoutXAxisAnchor *)centerX centerY:(NSLayoutYAxisAnchor *)centerY;

- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;


@end

NS_ASSUME_NONNULL_END

