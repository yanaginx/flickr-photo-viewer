//
//  UploadInfo.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 14/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UploadInfo : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *imageTitle;
@property (nonatomic, strong) NSString *imageDescription;
@property (nonatomic, strong, nullable) NSString *albumID;

- (instancetype)initWithImage:(UIImage *)image
                        title:(NSString *)title
                  description:(NSString *)imageDescription
                      albumID:(NSString * _Nullable)albumID;

@end

NS_ASSUME_NONNULL_END
