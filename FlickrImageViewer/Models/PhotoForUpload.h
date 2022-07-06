//
//  PhotoForUpload.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 06/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoForUpload : NSObject

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImage *image;

@end

NS_ASSUME_NONNULL_END
