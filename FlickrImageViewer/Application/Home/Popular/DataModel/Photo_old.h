//
//  Photo.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 27/06/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Photo_old : NSObject

@property (nonatomic, strong) NSUUID *identifier;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic) CGSize imageSize;

- (instancetype)initWithImageURL:(NSURL *)imageURL
                       imageSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
