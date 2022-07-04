//
//  AlbumInfo.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 04/07/2022.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlbumInfo : NSObject

@property (nonatomic, strong) NSURL *albumImageURL;
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic) NSInteger numberOfPhotos;

- (instancetype)initWithAlbumImageURL:(NSURL *)url
                            albumName:(NSString *)name
                          dateCreated:(NSDate *)date
                       numberOfPhotos:(NSInteger)number;

@end

NS_ASSUME_NONNULL_END
