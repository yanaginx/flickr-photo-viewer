//
//  UIImageView+Additions.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 05/07/2022.
//

#import "UIImageView+Additions.h"

@implementation UIImageView (Additions)

// Better ver with task cancelling
static char *taskKey;
static char *urlKey;

- (void)setImageUsingURL:(NSURL *)url {
    self.image = [UIImage imageNamed:@"img_placeholder"];
    
    NSURLSessionTask *oldTask = objc_getAssociatedObject(self, &taskKey);
    if (oldTask) {
        objc_setAssociatedObject(self, &taskKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [oldTask cancel];
    }
    objc_setAssociatedObject(self, &urlKey, url.absoluteString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSURLSessionTask *task = [[ImageManager sharedImageManager] fetchImageWithURL:url
                                                                       completion:^(UIImage * _Nullable image,
                                                                                    NSError * _Nullable error) {
        NSString *currentURL = objc_getAssociatedObject(self, &urlKey);
        if ([currentURL isEqualToString:url.absoluteString]) {
            objc_setAssociatedObject(self, &urlKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(self, &taskKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        if (image) {
            self.image = image;
        }
    }];
    
    objc_setAssociatedObject(self, &taskKey, task, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setImageUsingURL:(NSURL *)url completed:(void (^)(UIImage * _Nullable image,
                                                          NSError * _Nullable error))completionHandler {
    NSURLSessionTask *oldTask = objc_getAssociatedObject(self, &taskKey);
    if (oldTask) {
        objc_setAssociatedObject(self, &taskKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [oldTask cancel];
    }
    
    self.image = nil;
    
    objc_setAssociatedObject(self, &urlKey, url.absoluteString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSURLSessionTask *task = [[ImageManager sharedImageManager] fetchImageWithURL:url
                                                                       completion:^(UIImage * _Nullable image,
                                                                                    NSError * _Nullable error) {
        NSString *currentURL = objc_getAssociatedObject(self, &urlKey);
        if ([currentURL isEqualToString:url.absoluteString]) {
            objc_setAssociatedObject(self, &urlKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(self, &taskKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        if (error) {
            completionHandler(nil, error);
            return;
        }
        if (image) {
            completionHandler(image, nil);
            self.image = image;
        }
    }];
    
    objc_setAssociatedObject(self, &taskKey, task, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
