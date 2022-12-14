//
//  DynamicSizeCalculator.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 27/06/2022.
//

#import "DynamicSizeCalculator.h"

#define VALID_RATIO 4.0

@interface DynamicSizeCalculator ()

@property (nonatomic, strong) NSMutableDictionary *sizeCache;
@property (nonatomic, strong) NSMutableArray *leftOvers;
@property (nonatomic, strong) NSIndexPath *lastIndexPathAdded;

@end

@implementation DynamicSizeCalculator

- (CGSize)sizeForPhotoAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.sizeCache[indexPath]) {
        self.lastIndexPathAdded = indexPath;
        [self computeSizesAtIndexPath:indexPath];
    }
    CGSize size = [[self.sizeCache objectForKey:indexPath] CGSizeValue];
    if (size.width < 0.0 || size.height < 0.0) {
        size = CGSizeZero;
    }
    return size;
}

- (void)clearCache {
    [self.sizeCache removeAllObjects];
}

- (void)clearCacheAfterIndexPath:(NSIndexPath *)indexPath {
    // Remove the indexPath
    [self.sizeCache removeObjectForKey:indexPath];
    
    // Remove the indexPath for anything after
    for (NSIndexPath *existingIndexPath in [self.sizeCache allKeys]) {
        if ([indexPath compare:existingIndexPath] == NSOrderedDescending) {
            [self.sizeCache removeObjectForKey:existingIndexPath];
        }
    }
}

#pragma mark - Private methods

//- (void)computeSizesAtIndexPath:(NSIndexPath *)indexPath {
//    CGSize photoSize = [self.dataSource dynamicSizeCalculator:self
//                                 originalImageSizeAtIndexPath:indexPath];
//
//    if (photoSize.width < 1 || photoSize.height < 1) {
//        // Photo with no height or width
//        photoSize.width  = self.rowMaximumHeight;
//        photoSize.height = self.rowMaximumHeight;
//    }
//
//    [self.leftOvers addObject:[NSValue valueWithCGSize:photoSize]];
//
//    BOOL enoughContentForTheRow = NO;
//    CGFloat rowHeight = self.rowMaximumHeight;
//    CGFloat widthMultiplier = 1.0;
//
//    // Calculations for variable height grid
//    if (self.fixedHeight) {
//        CGFloat totalWidth = 0;
//        NSInteger index = 0;
//        for (NSValue *leftOver in self.leftOvers) {
//            CGSize leftOverSize = [leftOver CGSizeValue];
//            CGFloat scaledWidth = ceil((rowHeight * leftOverSize.width) / leftOverSize.height);
//            scaledWidth += self.interItemSpacing;
//
//            if ((totalWidth + scaledWidth * 0.66) > self.contentWidth) {
//                // Adding this photo would mean less than 2/3 of it would be visible
//                enoughContentForTheRow = YES;
//                [self.leftOvers removeObjectAtIndex:index];
//                break;
//            }
//
//            totalWidth += scaledWidth;
//            enoughContentForTheRow = (totalWidth > self.contentWidth);
//            index++;
//        }
//
//        if (enoughContentForTheRow) {
//            widthMultiplier = totalWidth / self.contentWidth;
//        }
//
//    } else {
//        CGFloat totalAspectRatio = 0.0;
//        CGFloat availableWidth = self.contentWidth - (self.leftOvers.count - 1) * self.interItemSpacing;
//
//        for (NSValue *leftOver in self.leftOvers) {
//            CGSize leftOverSize = [leftOver CGSizeValue];
//            totalAspectRatio += (leftOverSize.width / leftOverSize.height);
//        }
//
//        rowHeight = availableWidth / totalAspectRatio;
//        enoughContentForTheRow = rowHeight < self.rowMaximumHeight;
//    }
//
//    if (enoughContentForTheRow) {
//        // The line is full!
//
//        CGFloat availableSpace = self.contentWidth;
//        NSInteger index = 0;
//        for (NSValue *leftOver in self.leftOvers) {
//
//            CGSize leftOverSize = [leftOver CGSizeValue];
//
//            CGFloat newWidth = floor((rowHeight * leftOverSize.width) / leftOverSize.height);
//
//            if (self.fixedHeight) {
//                if (index == self.leftOvers.count - 1) {
//                    newWidth = availableSpace;
//                } else {
//                    newWidth = floor(newWidth * widthMultiplier);
//                }
//            } else {
//                newWidth = MIN(availableSpace, newWidth);
//            }
//
//            // Add the size in the cache
//            [self.sizeCache setObject:[NSValue valueWithCGSize:CGSizeMake(newWidth, rowHeight)]
//                               forKey:self.lastIndexPathAdded];
//
//            availableSpace -= newWidth;
//            availableSpace -= self.interItemSpacing;
//
//            // We need to keep track of the last index path added
//            self.lastIndexPathAdded = [NSIndexPath indexPathForItem:(self.lastIndexPathAdded.item + 1)
//                                                          inSection:self.lastIndexPathAdded.section];
//            index++;
//        }
//
//        [self.leftOvers removeAllObjects];
//    } else {
//        // The line is not full, let's ask the next photo and try to fill up the line
//        [self computeSizesAtIndexPath:[NSIndexPath indexPathForItem:(indexPath.item + 1)
//                                                          inSection:indexPath.section]];
//    }
//}

// Better ver
- (void)computeSizesAtIndexPath:(NSIndexPath *)indexPath {
    CGSize photoSize = [self.dataSource dynamicSizeCalculator:self originalImageSizeAtIndexPath:indexPath];
    [self.leftOvers addObject:[NSValue valueWithCGSize:photoSize]];
    
    BOOL enoughContentForTheRow = NO;
    CGFloat rowHeight = self.rowMaximumHeight;
    
    if (self.fixedHeight) {
        CGFloat totalWidth = 0;
        NSInteger index = 0;
        for (NSValue *leftOver in self.leftOvers) {
            CGFloat availableSpace = self.contentWidth - totalWidth;
            CGSize leftOverSize = [leftOver CGSizeValue];
            CGFloat scaledWidth = (leftOverSize.width / leftOverSize.height) * rowHeight;
            scaledWidth += self.interItemSpacing;
            
            if ((totalWidth + scaledWidth) > self.contentWidth) {
                enoughContentForTheRow = YES;
                if (scaledWidth > VALID_RATIO * availableSpace ||
                    availableSpace < 60) {
                    [self.leftOvers removeObjectAtIndex:index];
                }
                break;
            }
            totalWidth += scaledWidth;
            index++;
        }
    }
    
    if (enoughContentForTheRow) {
        // The line is full!
        CGFloat availableSpace = self.contentWidth;
        NSInteger index = 0;
        for (NSValue *leftOver in self.leftOvers) {
            CGSize leftOverSize = [leftOver CGSizeValue];
            
            CGFloat newWidth = (leftOverSize.width / leftOverSize.height) * rowHeight;
            
            if (self.fixedHeight) {
                if (index == self.leftOvers.count - 1) {
                    newWidth = availableSpace;
                }
            }
            
            // Add the size in the cache
            [self.sizeCache setObject:[NSValue valueWithCGSize:CGSizeMake(newWidth, rowHeight)]
                               forKey:self.lastIndexPathAdded];
            
            availableSpace -= newWidth;
            availableSpace -= self.interItemSpacing;
            
            // We need to keep track of the last index path added
            self.lastIndexPathAdded = [NSIndexPath indexPathForItem:(self.lastIndexPathAdded.item + 1)
                                                          inSection:self.lastIndexPathAdded.section];
            index++;
        }
        [self.leftOvers removeAllObjects];
        
    } else {
        // The line is not full, let's ask the next photo and try to fill up the line
        [self computeSizesAtIndexPath:[NSIndexPath indexPathForItem:(indexPath.item + 1)
                                                          inSection:indexPath.section]];
    }
}

#pragma mark - Custom accessors

- (NSMutableArray *)leftOvers {
    if (_leftOvers) return _leftOvers;
    _leftOvers = [NSMutableArray array];
    return _leftOvers;
}

- (NSMutableDictionary *)sizeCache {
    if (_sizeCache) return _sizeCache;
    _sizeCache = [NSMutableDictionary dictionary];
    return _sizeCache;
}



@end

