//
//  Photo.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 01/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Photo : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic) CGSize imageSize;

- (instancetype)initWithImageURL:(NSURL *)imageURL
                       imageSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
