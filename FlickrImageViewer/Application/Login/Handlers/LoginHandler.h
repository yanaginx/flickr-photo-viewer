//
//  LoginHandler.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 21/06/2022.
//

#import <Foundation/Foundation.h>
#import<AuthenticationServices/AuthenticationServices.h>

typedef NS_ENUM(NSUInteger, LoginHandlerErrorCode) {
    LoginHandlerErrorInvalidURL = 161100,
    LoginHandlerErrorNetworkError = 161101,
    LoginHandlerErrorNotValidData = 161102,
    LoginHandlerErrorServerError = 161103,
    LoginHandlerNoError = 161104
};

typedef NS_ENUM(NSUInteger, AuthenticationState) {
    GettingRequestToken,
    GettingAuthorization,
    GettingAccessToken,
    SavingUserInfo
};


NS_ASSUME_NONNULL_BEGIN

@protocol LoginHandlerDelegate <NSObject>

- (void)onFinishGettingRequestTokenWithErrorCode:(LoginHandlerErrorCode) errorCode;
- (void)requestAuthorizationUsingAuthSession:(ASWebAuthenticationSession *)authSession;
- (void)onFinishGettingAuthorizationWithErrorCode:(LoginHandlerErrorCode) errorCode;
- (void)onFinishGettingAccessTokenWithErrorCode:(LoginHandlerErrorCode) errorCode;
- (void)onFinishSavingUserInfo:(LoginHandlerErrorCode) errorCode;

@end

@interface LoginHandler : NSObject


@property (class, nonnull, readonly, strong) LoginHandler *sharedLoginHandler;

@property (nonatomic, weak) id<LoginHandlerDelegate> delegate;

- (void)startAuthenticationProcess;

NS_ASSUME_NONNULL_END

@end
