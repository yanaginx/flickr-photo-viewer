//
//  PublicPhotoCollectionViewCell.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 01/07/2022.
//

#import "PublicPhotoCollectionViewCell.h"
#import "../../../../Common/Extensions/UIView+Additions.h"

@implementation PublicPhotoCollectionViewCell

+ (NSString *)reuseIdentifier {
    return @"PublicPhotoCell";
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
//        self.backgroundColor = UIColor.redColor;
        [self addSubview:self.photoImageView];
    }
    return self;
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    return layoutAttributes;
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


#pragma mark - Custom Accessors

- (UIImageView *)photoImageView {
    if (!_photoImageView) {
        _photoImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoImageView.clipsToBounds = YES;
//        _photoImageView.layer.cornerRadius = 15;
        
        [self.contentView addSubview:_photoImageView];
        [_photoImageView setAnchorTop:self.topAnchor
                                 left:self.leftAnchor
                               bottom:self.bottomAnchor
                                right:self.rightAnchor
                           paddingTop:0
                          paddingLeft:0
                        paddingBottom:0
                         paddingRight:0
                                width:0
                               height:0];
    }
    return _photoImageView;
}

@end
