//
//  PublicPhotosViewController.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 30/06/2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PublicPhotosRefreshDelegate <NSObject>

- (void)cancelRefreshingAfterFetchingPublicPhotos;

@end

@interface PublicPhotosViewController : UIViewController

@property (nonatomic, weak) id<PublicPhotosRefreshDelegate> delegate;

- (void)getPhotosForFirstPage;

@end

NS_ASSUME_NONNULL_END
