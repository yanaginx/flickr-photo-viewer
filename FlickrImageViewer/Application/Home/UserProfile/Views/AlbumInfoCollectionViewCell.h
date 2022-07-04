//
//  AlbumInfoCollectionViewCell.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 04/07/2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlbumInfoCollectionViewCell : UICollectionViewCell

+ (NSString *)reuseIdentifier;
@property (nullable, nonatomic) UIImageView *albumImageView;
@property (nullable, nonatomic) UILabel *albumNameLabel;
@property (nullable, nonatomic) UILabel *dateCreatedLabel;
@property (nullable, nonatomic) UILabel *numberOfPhotosLabel;

- (void)configureAlbumInfoWithImageURL:(NSURL *)albumCoverURL
                                  name:(NSString *)albumName
                           dateCreated:(NSDate *)dateCreated
                        numberOfPhotos:(NSInteger)numberOfPhotos;

@end

NS_ASSUME_NONNULL_END
