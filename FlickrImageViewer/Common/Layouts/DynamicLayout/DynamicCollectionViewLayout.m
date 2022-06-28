//
//  DynamicCollectionViewLayout.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 27/06/2022.
//

#import "DynamicCollectionViewLayout.h"
#import "DynamicSizeCalculator.h"

@interface DynamicCollectionViewLayout () <DynamicSizeCalculatorDataSource>

@property (nonatomic, strong) DynamicSizeCalculator *dynamic;

@end

@implementation DynamicCollectionViewLayout

static CGFloat spacing = 6.0f;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.minimumLineSpacing = spacing;
        self.minimumInteritemSpacing = spacing;
        self.sectionInset = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    }
    return self;
}

- (CGSize)sizeForPhotoAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat contentWidth  = self.collectionView.bounds.size.width;
    CGFloat interitemSpacing = 0.0;
    
    contentWidth -= (self.sectionInset.left + self.sectionInset.right);
    interitemSpacing = self.minimumInteritemSpacing;

    self.dynamic.contentWidth = contentWidth;
    self.dynamic.interItemSpacing = interitemSpacing;
    
    return [self.dynamic sizeForPhotoAtIndexPath:indexPath];
}

- (void)clearCache {
    [self.dynamic clearCache];
}

- (void)clearCacheAfterIndexPath:(NSIndexPath *)indexPath {
    [self.dynamic clearCacheAfterIndexPath:indexPath];
}

- (CGFloat)rowMaximumHeight {
    return self.dynamic.rowMaximumHeight;
}

- (void)setRowMaximumHeight:(CGFloat)rowMaximumHeight {
    self.dynamic.rowMaximumHeight = rowMaximumHeight;
}

- (BOOL)fixedHeight {
    return self.dynamic.fixedHeight;
}

- (void)setFixedHeight:(BOOL)fixedHeight {
    self.dynamic.fixedHeight = fixedHeight;
}

- (CGSize)dynamicSizeCalculator:(DynamicSizeCalculator *)layout
   originalImageSizeAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource dynamicCollectionViewLayout:self
                           originalImageSizeAtIndexPath:indexPath];
}

#pragma mark - Lazy Loading

- (DynamicSizeCalculator *)dynamic {
    if (!_dynamic) {
        _dynamic = [[DynamicSizeCalculator alloc] init];
        _dynamic.rowMaximumHeight = 200;
        _dynamic.fixedHeight = NO;
        _dynamic.dataSource = self;
    }
    return _dynamic;
}

@end
