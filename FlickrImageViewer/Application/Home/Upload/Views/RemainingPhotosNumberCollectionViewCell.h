//
//  RemaningPhotosNumberCollectionViewCell.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 08/07/2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RemainingPhotosNumberCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *numberOfRemainingPhotosLabel;

+ (NSString *)reuseIdentifier;
- (void)configureWithNumberOfPhotos:(NSInteger)numberOfPhotos;

@end

NS_ASSUME_NONNULL_END
