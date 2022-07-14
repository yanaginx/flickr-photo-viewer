//
//  UploadInfo.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 14/07/2022.
//

#import "UploadInfo.h"

@implementation UploadInfo

- (instancetype)initWithImage:(UIImage *)image
                        title:(NSString *)title
                  description:(NSString *)imageDescription
                      albumID:(NSString *)albumID {
    self = [super init];
    if (self) {
        self.image = image;
        self.imageTitle = title;
        self.imageDescription = imageDescription;
        self.albumID = albumID;
    }
    return self;
}

@end
