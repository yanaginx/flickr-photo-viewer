//
//  UIView+Additions.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)

- (void)setAnchorTop:(NSLayoutYAxisAnchor *)top
                left:(NSLayoutXAxisAnchor *)left
              bottom:(NSLayoutYAxisAnchor *)bottom
               right:(NSLayoutXAxisAnchor *)right
          paddingTop:(CGFloat)paddingTop
         paddingLeft:(CGFloat)paddingLeft
       paddingBottom:(CGFloat)paddingBottom
        paddingRight:(CGFloat)paddingRight
               width:(CGFloat)width
              height:(CGFloat)height {
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [[self.topAnchor constraintEqualToAnchor:top constant:paddingTop] setActive:YES];
    [[self.leftAnchor constraintEqualToAnchor:left constant:paddingLeft] setActive:YES];
    [[self.bottomAnchor constraintEqualToAnchor:bottom constant:paddingBottom] setActive:YES];
    [[self.rightAnchor constraintEqualToAnchor:right constant:paddingRight] setActive:YES];
    
    if (width != 0) {
        [[self.widthAnchor constraintEqualToConstant:width] setActive:YES];
    }
    
    if (height != 0) {
        [[self.heightAnchor constraintEqualToConstant:height] setActive:YES];
    }
}

- (void)setAnchorTop:(NSLayoutYAxisAnchor *)top paddingTop:(CGFloat)paddingTop {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.topAnchor constraintEqualToAnchor:top constant:paddingTop] setActive:YES];
}

- (void)setAnchorLeft:(NSLayoutXAxisAnchor *)left paddingLeft:(CGFloat)paddingLeft {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.leftAnchor constraintEqualToAnchor:left constant:paddingLeft] setActive:YES];
}

- (void)setAnchorRight:(NSLayoutXAxisAnchor *)right paddingRight:(CGFloat)paddingRight {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.rightAnchor constraintEqualToAnchor:right constant:paddingRight] setActive:YES];
}

- (void)setAnchorBottom:(NSLayoutYAxisAnchor *)bottom paddingBottom:(CGFloat)paddingBottom {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.bottomAnchor constraintEqualToAnchor:bottom constant:paddingBottom] setActive:YES];
}

- (void)setAnchorWidth:(CGFloat)width {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.widthAnchor constraintEqualToConstant:width] setActive:YES];
}

- (void)setAnchorHeight:(CGFloat)height {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.heightAnchor constraintEqualToConstant:height] setActive:YES];
}

- (void)setAnchorCenterX:(NSLayoutXAxisAnchor *)centerX centerY:(NSLayoutYAxisAnchor *)centerY {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.centerXAnchor constraintEqualToAnchor:centerX] setActive:YES];
    [[self.centerYAnchor constraintEqualToAnchor:centerY] setActive:YES];
}

@end

