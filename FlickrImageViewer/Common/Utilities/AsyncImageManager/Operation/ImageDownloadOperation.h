//
//  ImageDownloadOperation.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 19/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageDownloadOperation : NSOperation

@property(readonly, getter=isAsynchronous) BOOL asynchronous;
@property(readonly, getter=isExecuting) BOOL executing;
@property(readonly, getter=isFinished) BOOL finished;

@property NSString *identifier;
@property NSURL *imageURL;
@property UIImage *fetchedData;
@property NSError *error;

- (instancetype)initWithIdentifier:(NSString *)identifier
                          imageURL:(NSURL *)imageURL;

@end

NS_ASSUME_NONNULL_END
