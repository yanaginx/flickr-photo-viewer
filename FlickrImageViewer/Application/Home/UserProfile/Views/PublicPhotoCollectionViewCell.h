//
//  PublicPhotoCollectionViewCell.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 01/07/2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PublicPhotoCollectionViewCell : UICollectionViewCell

@property (nullable, nonatomic) UIImageView *photoImageView;
@property NSUUID *representedIdentifier;

+ (NSString *)reuseIdentifier;
- (void)configureWithImage:(UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
