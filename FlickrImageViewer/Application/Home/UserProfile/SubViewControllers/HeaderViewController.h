//
//  HeaderViewController.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 30/06/2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HeaderViewController : UIViewController

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *numberOfPhotosLabel;

- (void)reloadProfileInfo;

@end

NS_ASSUME_NONNULL_END
