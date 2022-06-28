//
//  Photo.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 27/06/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Photo : NSObject

@property (nonatomic, strong) NSUUID *identifier;
@property (nonatomic, strong) NSURL *imageURL;

- (instancetype)initWithImageURL:(NSURL *)imageURL;

@end

NS_ASSUME_NONNULL_END
