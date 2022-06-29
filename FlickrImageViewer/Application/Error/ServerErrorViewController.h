//
//  SomeErrorViewController.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 29/06/2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ServerErrorViewDelegate <NSObject>

- (void)onRetryForServerErrorClicked;

@end

@interface ServerErrorViewController : UIViewController

@property (nonatomic, weak) id<ServerErrorViewDelegate> delegate;

@end


NS_ASSUME_NONNULL_END
