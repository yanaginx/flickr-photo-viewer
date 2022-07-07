//
//  AlbumInfoCollectionViewCell.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 04/07/2022.
//

#import "AlbumInfoCollectionViewCell.h"
#import "../UserProfileConstants.h"

#import "../../../../Common/Extensions/NSDate+Additions.h"
#import "../../../../Common/Extensions/UIImageView+Additions.h"

@interface AlbumInfoCollectionViewCell ()

@property (nullable, nonatomic) UIImageView *albumImageView;
@property (nullable, nonatomic) UILabel *albumNameLabel;
@property (nullable, nonatomic) UILabel *dateCreatedLabel;
@property (nullable, nonatomic) UILabel *numberOfPhotosLabel;

@end

@implementation AlbumInfoCollectionViewCell

+ (NSString *)reuseIdentifier {
    return @"AlbumInfoCell";
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        self.layer.cornerRadius = 15;
        [self addSubview:self.albumImageView];
        [self addSubview:self.albumNameLabel];
        [self addSubview:self.dateCreatedLabel];
        [self addSubview:self.numberOfPhotosLabel];
    }
    return self;
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    return layoutAttributes;
}

#pragma mark - Operations
- (void)configureAlbumInfoCellWithImageURL:(NSURL *)imageURL {
    [self.albumImageView setImageUsingURL:imageURL];
}

- (void)configureAlbumInfoCellWithName:(NSString *)albumName {
    self.albumNameLabel.text = albumName;
}

- (void)configureAlbumInfoCellWithDateCreated:(NSDate *)dateCreated {
    self.dateCreatedLabel.text = [NSDate stringForDisplayFromDate:dateCreated];
}

- (void)configureAlbumInfoCellWithNumberOfPhotos:(NSInteger)numberOfPhotos {
    self.numberOfPhotosLabel.text = [NSString stringWithFormat:@"%ld photos", (long)numberOfPhotos];
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
        _albumNameLabel.font = [UIFont systemFontOfSize:18
                                                 weight:UIFontWeightBold];
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
        _dateCreatedLabel.textColor = UIColor.darkGrayColor;
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
        _numberOfPhotosLabel.textColor = UIColor.darkGrayColor;
    }
    return _numberOfPhotosLabel;
}

@end
