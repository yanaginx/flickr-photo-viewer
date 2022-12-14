//
//  Photo.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 01/07/2022.
//

#import "Photo.h"

@implementation Photo

- (instancetype)initWithImageURL:(NSURL *)imageURL
                       imageSize:(CGSize)size {
    self = [super init];
    if (self) {
//        self.identifier = [[NSUUID alloc] init];
        self.identifier = imageURL.absoluteString;
        self.imageURL = imageURL;
        self.imageSize = size;
    }
    return self;
}

@end
