//
//  AccountManager.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 02/07/2022.
//

#import "AccountManager.h"

#import "../../../Models/User.h"
#import "../../Extensions/NSUserDefaults+Additions.h"

#define kCurrentUserKey @"currentUser"

@implementation AccountManager


#pragma mark - Accessors
+ (NSString * _Nullable)userNSID {
    User *currentUser = (User *)[NSUserDefaults.standardUserDefaults
                                 loadUserObjectWithKey:kCurrentUserKey];
    if (currentUser) {
        return currentUser.NSID;
    }
    NSLog(@"[ERROR] No info yet");
    return nil;
}

+ (NSString * _Nullable)userAccessToken {
    User *currentUser = (User *)[NSUserDefaults.standardUserDefaults
                                 loadUserObjectWithKey:kCurrentUserKey];
    if (currentUser) {
        return currentUser.accessToken;
    }
    NSLog(@"[ERROR] No info yet");
    return nil;
}

+ (NSString * _Nullable)userSecretToken {
    User *currentUser = (User *)[NSUserDefaults.standardUserDefaults
                                 loadUserObjectWithKey:kCurrentUserKey];
    if (currentUser) {
        return currentUser.secretToken;
    }
    NSLog(@"[ERROR] No info yet");
    return nil;
}

+ (BOOL)isUserLoggedIn {
    return [NSUserDefaults.standardUserDefaults boolForKey:@"isLoggedIn"];
}

#pragma mark - Methods
+ (void)setAccountInfoWithUserNSID:(NSString *)nsid
                   userAccessToken:(NSString *)accessToken
                   userSecretToken:(NSString *)secretToken {
    
    BOOL isLoggedIn = [NSUserDefaults.standardUserDefaults boolForKey:@"isLoggedIn"];
    if (isLoggedIn) {
        NSLog(@"[ERROR] logged in already, log out before using this");
        return;
    }
    
    User *user = [[User alloc] initWithNSID:nsid
                                accessToken:accessToken
                                secretToken:secretToken];
    [NSUserDefaults.standardUserDefaults saveUserObject:user
                                                    key:kCurrentUserKey];
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"isLoggedIn"];
}

+ (void)removeAccountInfo {
    [NSUserDefaults.standardUserDefaults removeObjectForKey:kCurrentUserKey];
}


@end
