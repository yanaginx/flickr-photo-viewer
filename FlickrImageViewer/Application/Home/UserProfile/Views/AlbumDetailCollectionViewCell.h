//
//  AlbumDetailCollectionViewCell.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 04/07/2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlbumDetailCollectionViewCell : UICollectionViewCell

@property (nullable, nonatomic) UIImageView *photoImageView;
@property NSString *representedIdentifier;

+ (NSString *)reuseIdentifier;
- (void)configureWithImage:(UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
