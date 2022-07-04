//
//  AlbumInfoCollectionViewCell.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 04/07/2022.
//

#import "AlbumInfoCollectionViewCell.h"
#import "../UserProfileConstants.h"

@implementation AlbumInfoCollectionViewCell

+ (NSString *)reuseIdentifier {
    return @"AlbumInfoCell";
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = UIColor.redColor;
        self.layer.cornerRadius = 15;
        [self addSubview:self.albumImageView];
        [self addSubview:self.albumNameLabel];
        [self addSubview:self.dateCreatedLabel];
        [self addSubview:self.numberOfPhotosLabel];
    }
    return self;
}

#pragma mark - Custom Accessors

- (UIImageView *)albumImageView {
    if (!_albumImageView) {
        CGRect imageViewFrame = CGRectMake(kAlbumInfoAlbumImageX,
                                           kAlbumInfoAlbumImageY,
                                           kAlbumInfoAlbumImageSize,
                                           kAlbumInfoAlbumImageSize);
        _albumImageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
        _albumImageView.image = [UIImage imageNamed:@"ic_no_data"];
        _albumImageView.contentMode = UIViewContentModeScaleAspectFill;
        _albumImageView.clipsToBounds = YES;
    }
    return _albumImageView;
}

- (UILabel *)albumNameLabel {
    if (!_albumNameLabel) {
        CGRect albumNameLabelFrame = CGRectMake(kAlbumInfoAlbumNameX,
                                                kAlbumInfoAlbumNameY,
                                                kAlbumInfoAlbumNameWidth,
                                                kAlbumInfoAlbumNameHeight);
        _albumNameLabel = [[UILabel alloc] initWithFrame:albumNameLabelFrame];
        _albumNameLabel.clipsToBounds = YES;
        _albumNameLabel.text = @"Album Name";
    }
    return _albumNameLabel;
}

- (UILabel *)dateCreatedLabel {
    if (!_dateCreatedLabel) {
        CGRect dateCreatedLabelFrame = CGRectMake(kAlbumInfoDateCreatedX,
                                                  kAlbumInfoDateCreatedY,
                                                  kAlbumInfoDateCreatedWidth,
                                                  kAlbumInfoDateCreatedHeight);
        _dateCreatedLabel = [[UILabel alloc] initWithFrame:dateCreatedLabelFrame];
//        _dateCreatedLabel.clipsToBounds = YES;
        _dateCreatedLabel.text = @"DAY MONTH YEAR";
    }
    return _dateCreatedLabel;
}

- (UILabel *)numberOfPhotosLabel {
    if (!_numberOfPhotosLabel) {
        CGRect numberOfPhotosLabelFrame = CGRectMake(kAlbumInfoNumberOfPhotosX,
                                                     kAlbumInfoNumberOfPhotosY,
                                                     kAlbumInfoNumberOfPhotosWidth,
                                                     kAlbumInfoNumberOfPhotosHeight);
        _numberOfPhotosLabel = [[UILabel alloc] initWithFrame:numberOfPhotosLabelFrame];
        _numberOfPhotosLabel.clipsToBounds = YES;
        _numberOfPhotosLabel.text = @"# Photos";
    }
    return _numberOfPhotosLabel;
}

@end
