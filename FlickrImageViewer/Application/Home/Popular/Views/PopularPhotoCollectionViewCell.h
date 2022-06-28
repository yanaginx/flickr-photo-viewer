//
//  PopularPhotoCollectionViewCell.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 27/06/2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PopularPhotoCollectionViewCell : UICollectionViewCell

@property (nullable, nonatomic) UIImageView *photoImageView;

- (void)configureWithImage:(UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
