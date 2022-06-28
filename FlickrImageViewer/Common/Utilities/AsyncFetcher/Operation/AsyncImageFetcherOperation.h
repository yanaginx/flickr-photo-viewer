//
//  AsyncImageFetcherOperation.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 28/06/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AsyncImageFetcherOperation : NSOperation

@property NSUUID *identifier;
@property NSURL *imageURL;
@property UIImage *fetchedData;
@property NSError *error;

- (instancetype)initWithIdentifier:(NSUUID *)identifier
                          imageURL:(NSURL *)imageURL;

@end

NS_ASSUME_NONNULL_END
