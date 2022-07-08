//
//  RemaningPhotosNumberCollectionViewCell.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 08/07/2022.
//

#import "RemainingPhotosNumberCollectionViewCell.h"

@implementation RemainingPhotosNumberCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:14.0/255 green:122.0/255 blue:254.0/255 alpha:0.5];
        [self addSubview:self.numberOfRemainingPhotosLabel];
    }
    return self;
}

+ (NSString *)reuseIdentifier {
    return @"RemainingPhotosNumberCell";
}

- (void)configureWithNumberOfPhotos:(NSInteger)numberOfPhotos {
    NSString *remainingPhotosNumberText = [NSString stringWithFormat:@"+%lu",
                                           (unsigned long)numberOfPhotos];
    _numberOfRemainingPhotosLabel.text = remainingPhotosNumberText;
}

- (UILabel *)numberOfRemainingPhotosLabel {
    if (!_numberOfRemainingPhotosLabel) {
        _numberOfRemainingPhotosLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        _numberOfRemainingPhotosLabel.clipsToBounds = YES;
        _numberOfRemainingPhotosLabel.textAlignment = NSTextAlignmentCenter;
        _numberOfRemainingPhotosLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        [self.contentView addSubview:_numberOfRemainingPhotosLabel];
    }
    return _numberOfRemainingPhotosLabel;
}
@end
