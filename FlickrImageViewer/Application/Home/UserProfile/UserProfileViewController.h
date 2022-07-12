//
//  UserProfileViewController.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 25/06/2022.
//

#import <UIKit/UIKit.h>
#import "SubViewControllers/HeaderViewController.h"

typedef NS_ENUM(NSUInteger, CurrentProfileSubViewController) {
    PublicPhotos = 151611,
    Albums = 151612
};

@class PublicPhotosViewController;
@class AlbumViewController;
NS_ASSUME_NONNULL_BEGIN

@interface UserProfileViewController : UIViewController

@property (nonatomic, strong) HeaderViewController *headerViewController;
@property (nonatomic, strong) PublicPhotosViewController *publicPhotoViewController;
@property (nonatomic, strong) AlbumViewController *albumViewController;

- (CurrentProfileSubViewController)currentSubViewController;

@end

NS_ASSUME_NONNULL_END
