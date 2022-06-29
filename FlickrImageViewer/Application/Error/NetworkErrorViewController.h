//
//  NetworkErrorViewController.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 29/06/2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NetworkErrorViewDelegate <NSObject>

- (void)onRetryForNetworkErrorClicked;

@end

@interface NetworkErrorViewController : UIViewController

@property (nonatomic, weak) id<NetworkErrorViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
