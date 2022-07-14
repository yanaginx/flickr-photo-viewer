//
//  GalleryViewModel.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 14/07/2022.
//

#import "GalleryViewModel.h"
#import "../Handlers/GalleryManager.h"

#define kTargetSize CGSizeMake(200, 200)

@interface GalleryViewModel ()

@property (nonatomic, strong) GalleryManager *galleryManager;

@end

@implementation GalleryViewModel

- (instancetype)initWithGalleryManager:(GalleryManager *)galleryManager {
    self = [super init];
    if (self) {
        self.galleryManager = galleryManager;
    }
    return self;
}

- (NSUInteger)numberOfItems {
    return self.galleryManager.fetchResult.count;
}

- (UIImage *)itemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *photoAsset = [self.galleryManager.fetchResult objectAtIndex:indexPath.item];
    [self.galleryManager.imageCacheManager requestImageForAsset:photoAsset
                                                     targetSize:kTargetSize
                                                    contentMode:PHImageContentModeAspectFill
                                                        options:nil
                                                  resultHandler:^(UIImage * _Nullable result,
                                                                  NSDictionary * _Nullable info) {
        
    }];
    return nil;
}

@end
