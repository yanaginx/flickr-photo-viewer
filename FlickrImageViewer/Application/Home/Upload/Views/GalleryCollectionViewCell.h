//
//  GalleryCollectionViewCell.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 06/07/2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GalleryCollectionViewCell : UICollectionViewCell

@property (nullable, nonatomic) UIImageView *photoImageView;
@property NSString *localIdentifier;

+ (NSString *)reuseIdentifier;
- (void)configureWithImage:(UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
