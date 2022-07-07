//
//  PermissionErrorViewController.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 07/07/2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PermissionErrorViewDelegate <NSObject>

- (void)onRetryForPermissionErrorClicked;

@end

@interface PermissionErrorViewController : UIViewController

@property (nonatomic, weak) id<PermissionErrorViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
