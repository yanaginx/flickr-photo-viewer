//
//  LoadingButton.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 22/06/2022.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoadingButton : UIButton

- (void)showLoading;
- (void)hideLoading;

@end

NS_ASSUME_NONNULL_END
