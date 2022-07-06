//
//  UISegmentedControl+Additions.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 05/07/2022.
//

#import "UISegmentedControl+Additions.h"
#import "UIImage+Additions.h"

@implementation UISegmentedControl (Additions)


#pragma mark - Private methods
- (void)removeBorder {
    NSLog(@"%s : %f x %f", __func__, self.bounds.size.width, self.bounds.size.height);
    UIImage *backgroundImage = [UIImage getColoredRectImageWithColor:UIColor.whiteColor.CGColor
                                                                size:self.bounds.size];
    [self setBackgroundImage:backgroundImage
                    forState:UIControlStateNormal
                  barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:backgroundImage
                    forState:UIControlStateSelected
                  barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:backgroundImage
                    forState:UIControlStateHighlighted
                  barMetrics:UIBarMetricsDefault];
    
    CGSize dividerSize = CGSizeMake(1.0, self.bounds.size.height);
    UIImage *dividerImage = [UIImage getColoredRectImageWithColor:UIColor.whiteColor.CGColor
                                                             size:dividerSize];
    [self setDividerImage:dividerImage
      forLeftSegmentState:UIControlStateSelected
        rightSegmentState:UIControlStateNormal
               barMetrics:UIBarMetricsDefault];
    
    NSDictionary *normalTextAttribute = [NSDictionary dictionaryWithObject:UIColor.grayColor
                                                                            forKey:NSForegroundColorAttributeName];
    [self setTitleTextAttributes:normalTextAttribute forState:UIControlStateNormal];
    
    NSDictionary *selectedTextAttribute = [NSDictionary dictionaryWithObject:[UIColor colorWithRed:67/255
                                                                                             green:129/255
                                                                                              blue:244/255
                                                                                             alpha:1.0]
                                                                      forKey:NSForegroundColorAttributeName];
    [self setTitleTextAttributes:selectedTextAttribute forState:UIControlStateSelected];
    
    self.tintColor = [UIColor colorWithRed:67/255 green:129/255 blue:244/255 alpha:1.0];
}

- (void)addUnderlineForSelectedSegment {
    [self removeBorder];
    CGFloat underlineWidth = self.bounds.size.width / (CGFloat)self.numberOfSegments;
    CGFloat underlineHeight = 4.0;
    CGFloat underlineXPosition = (CGFloat)(self.selectedSegmentIndex * (NSInteger)underlineWidth);
    CGFloat underlineYPosition = self.bounds.size.height - 4.0;
    CGRect underlineFrame = CGRectMake(underlineXPosition,
                                       underlineYPosition,
                                       underlineWidth,
                                       underlineHeight);
    UIView *underline = [[UIView alloc] initWithFrame:underlineFrame];
    underline.backgroundColor = [UIColor colorWithRed:67/255 green:129/255 blue:244/255 alpha:1.0];
    underline.tag = 1;
    [self addSubview:underline];
}

- (void)changeUnderlinePosition {
    UIView *underline = [self viewWithTag:1];
    if (underline == nil) return;
    CGFloat underlineFinalXPosition = (self.bounds.size.width / (CGFloat)self.numberOfSegments) * (CGFloat)self.selectedSegmentIndex;
    
    CGFloat underlineY = underline.frame.origin.y;
    CGFloat underlineWidth = underline.frame.size.width;
    CGFloat underlineHeight = underline.frame.size.height;
    
    
    [UIView animateWithDuration:0.1
                     animations:^{
        underline.frame = CGRectMake(underlineFinalXPosition,
                                     underlineY,
                                     underlineWidth,
                                     underlineHeight);
    }];
}


@end
