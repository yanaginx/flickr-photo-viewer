//
//  AccountManager.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 02/07/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AccountManager : NSObject

+ (NSString * _Nullable)userNSID;
+ (NSString * _Nullable)userAccessToken;
+ (NSString * _Nullable)userSecretToken;
+ (BOOL)isUserLoggedIn;

+ (void)setAccountInfoWithUserNSID:(NSString *)nsid
                   userAccessToken:(NSString *)accessToken
                   userSecretToken:(NSString *)secretToken;
+ (void)removeAccountInfo;


@end

NS_ASSUME_NONNULL_END
