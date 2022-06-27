//
//  DynamicSizeCalculator.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 27/06/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol DynamicSizeCalculatorDataSource;

@interface DynamicSizeCalculator : NSObject

@property (nonatomic, weak) id <DynamicSizeCalculatorDataSource> dataSource;
@property CGFloat rowMaximumHeight;
@property BOOL fixedHeight;
@property CGFloat contentWidth;
@property CGFloat interItemSpacing;

- (CGSize)sizeForPhotoAtIndexPath:(NSIndexPath *)indexPath;
- (void)clearCache;
- (void)clearCacheAfterIndexPath:(NSIndexPath *)indexPath;

@end

@protocol DynamicSizeCalculatorDataSource <NSObject>
- (CGSize)dynamicSizeCalculator:(DynamicSizeCalculator *)layout
   originalImageSizeAtIndexPath:(NSIndexPath *)indexPath;
@end

