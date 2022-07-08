//
//  AlbumPickerViewController.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 08/07/2022.
//

#import <UIKit/UIKit.h>

@class AlbumInfo;

NS_ASSUME_NONNULL_BEGIN

@protocol AlbumPickerDelegate <NSObject>

- (void)onFinishSelectAlbumInfo:(AlbumInfo * _Nullable)selectedAlbumInfo;

@end

@interface AlbumPickerViewController : UIViewController

@property (nonatomic, weak) id<AlbumPickerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
