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
- (void)configureAlbumInfoCellWithImage:(UIImage *)image;
- (void)configureAlbumInfoCellWithName:(NSString *)albumName;
- (void)configureAlbumInfoCellWithDateCreated:(NSDate *)dateCreated;
- (void)configureAlbumInfoCellWithNumberOfPhotos:(NSInteger)numberOfPhotos;

@end

NS_ASSUME_NONNULL_END
