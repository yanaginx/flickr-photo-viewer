//
//  PhotoForUpload.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 06/07/2022.
//

#import "PhotoForUpload.h"

@implementation PhotoForUpload

- (instancetype)initWithImageURL:(NSURL *)imageURL
                           image:(UIImage *)image {
    self = [super init];
    if (self) {
        self.imageURL = imageURL;
        self.image = image;
    }
    return self;
}
@end
