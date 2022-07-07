//
//  GalleryCollectionViewCell.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 06/07/2022.
//

#import "GalleryCollectionViewCell.h"
#import "../../../../Common/Extensions/UIView+Additions.h"

@interface GalleryCollectionViewCell ()


@end

@implementation GalleryCollectionViewCell

+ (NSString *)reuseIdentifier {
    return @"GalleryPhotoCell";
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self addSubview:self.photoImageView];
        UIView *coloredView = [[UIView alloc] initWithFrame:self.bounds];
        coloredView.backgroundColor = UIColor.redColor;
        self.selectedBackgroundView = coloredView;
    }
    return self;
}

#pragma mark - Operations

- (void)configureWithImage:(UIImage *)image {
    self.photoImageView.image = image;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.photoImageView removeFromSuperview];
    self.photoImageView = nil;
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    return layoutAttributes;
}

#pragma mark - Custom Accessors

- (UIImageView *)photoImageView {
    if (!_photoImageView) {
        _photoImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoImageView.clipsToBounds = YES;
        _photoImageView.layer.cornerRadius = 30.0f;
        
        [self.contentView addSubview:_photoImageView];
//        [_photoImageView setAnchorTop:self.topAnchor
//                                 left:self.leftAnchor
//                               bottom:self.bottomAnchor
//                                right:self.rightAnchor
//                           paddingTop:0
//                          paddingLeft:0
//                        paddingBottom:0
//                         paddingRight:0
//                                width:0
//                               height:0];
    }
    return _photoImageView;
}

@end
