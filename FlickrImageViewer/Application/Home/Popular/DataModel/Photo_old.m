//
//  Photo.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 27/06/2022.
//

#import "Photo_old.h"

@implementation Photo_old

- (instancetype)initWithImageURL:(NSURL *)imageURL
                       imageSize:(CGSize)size {
    self = [super init];
    if (self) {
        self.identifier = [[NSUUID alloc] init];
        self.imageURL = imageURL;
        self.imageSize = size;
    }
    return self;
}

@end
