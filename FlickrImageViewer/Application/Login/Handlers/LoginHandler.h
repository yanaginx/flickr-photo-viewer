//
//  LoginHandler.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 21/06/2022.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LoginHandlerError) {
    LoginHandlerErrorInvalidURL,
    LoginHandlerErrorNetworkError,
    LoginHandlerErrorNotValidData
};

@interface LoginHandler : NSObject

NS_ASSUME_NONNULL_BEGIN

@property (class, nonnull, readonly, strong) LoginHandler *sharedLoginHandler;


- (NSURL *)authorizationURL;

- (NSString *)userAccessToken;
- (NSString *)userTokenSecret;

- (void)getRequestTokenWithCompletionHandler:(void (^)(NSString * _Nullable oauthToken,
                                                       NSString * _Nullable oauthTokenSecret,
                                                       NSError * _Nullable error))completion;

- (void)getAccessTokenWithCompletionHandler:(void (^)(NSString * _Nullable oauthToken,
                                                      NSString * _Nullable oauthTokenSecret,
                                                      NSError * _Nullable error))completion;

- (void)parseTokenAndVerifierFromQuery:(NSString *)queryString;

- (void)removeUserAccessTokenAndSecret;

NS_ASSUME_NONNULL_END

@end
