//
//  SSSnackbar.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 15/07/2022.
//
//  Copyright (c) 2015 Sam Stone. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SnackbarAppearDuration) {
    SnackbarDurationLong = 5,
    SnackbarDurationShort = 3,
    SnackbarDurationInfinite = -1
};

IB_DESIGNABLE
@interface SSSnackbar : UIView

@property (assign, nonatomic) NSTimeInterval duration;
@property (assign, nonatomic) BOOL actionIsLongRunning;
@property (strong, nonatomic) void (^actionBlock)(SSSnackbar *sender);
@property (strong, nonatomic) void (^dismissalBlock)(SSSnackbar *sender);

- (instancetype)initWithMessage:(NSString *)message
                     actionText:(NSString *)actionText
                       duration:(NSTimeInterval)duration
                    actionBlock:(void (^)(SSSnackbar *sender))actionBlock
                 dismissalBlock:(void (^)(SSSnackbar *sender))dismissalBlock;
+ (instancetype)snackbarWithMessage:(NSString *)message
                         actionText:(NSString *)actionText
                           duration:(NSTimeInterval)duration
                        actionBlock:(void (^)(SSSnackbar *sender))actionBlock
                     dismissalBlock:(void (^)(SSSnackbar *sender))dismissalBlock;

+ (instancetype)snackbarWithContextView:(UIView *)contextView
                                message:(NSString *)message
                             actionText:(NSString *)actionText
                               duration:(SnackbarAppearDuration)duration
                            actionBlock:(void (^)(SSSnackbar *sender))actionBlock;
                            

- (void)show;
- (void)display;
- (void)dismiss;
- (void)dismissAnimated:(BOOL)animated;

@end
