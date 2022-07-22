//
//  UIImageView+Additions.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 05/07/2022.
//

#import "UIImageView+Additions.h"
#import "../Constants/Constants.h"
#import "../Utilities/ImageManager/ImageManager.h"
#import "../Utilities/AsyncFetcher/AsyncImageFetcher.h"

@implementation UIImageView (Additions)

- (void)setImageUsingURL:(NSURL *)url {
    UIImage *fetchedData = [AsyncImageFetcher.sharedImageFetcher fetchedDataForIdentifier:url.absoluteString];
    if (fetchedData) {
        self.image = fetchedData;
    } else {
        [[AsyncImageFetcher sharedImageFetcher] fetchAsyncForIdentifier:url.absoluteString
                                                               imageURL:url
                                                             completion:^(UIImage * _Nullable image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = nil;
                if (image) {
                    self.image = image;
                }
            });
        }];
    }
}

@end
