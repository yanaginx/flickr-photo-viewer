//
//  AlbumViewController.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 30/06/2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AlbumRefreshDelegate <NSObject>

- (void)cancelRefreshingAfterFetchingAlbums;

@end

@interface AlbumViewController : UIViewController

@property (nonatomic, weak) id<AlbumRefreshDelegate> delegate;
@property (nonatomic, weak) UINavigationController *profileNavigationController;

- (void)getAlbumsForFirstPage;

@end

NS_ASSUME_NONNULL_END
