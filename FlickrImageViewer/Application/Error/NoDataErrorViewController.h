//
//  NoDataErrorViewController.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 29/06/2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NoDataErrorViewDelegate <NSObject>

- (void)onRetryForNoDataErrorClicked;

@end

@interface NoDataErrorViewController : UIViewController

@property (nonatomic, weak) id<NoDataErrorViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
