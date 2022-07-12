//
//  UserProfileManager.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 01/07/2022.
//

#import "UserProfileManager.h"
#import "../../../Login/Handlers/LoginHandler.h"

#import "../../../../Models/Photo.h"
#import "../../../../Common/Utilities/OAuth1.0/OAuth.h"
#import "../../../../Common/Utilities/ImageURLBuilder/ImageURLBuilder.h"
#import "../../../../Common/Utilities/AccountManager/AccountManager.h"
#import "../../../../Common/Constants/Constants.h"

@implementation UserProfileManager

#pragma mark - Make request
- (void)getUserProfileWithCompletionHandler:(void (^)(NSURL * _Nullable,
                                                      NSString * _Nullable,
                                                      NSString * _Nullable,
                                                      NSError * _Nullable))completion {
    NSURLRequest *request = [self _userProfileURLRequest];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data,
                                                         NSURLResponse *response,
                                                         NSError *error) {
        if (error) {
            if ([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."] ||
                [error.localizedDescription isEqualToString:@"The request timed out."]) {
                error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                            code:kNetworkError
                                        userInfo:nil];
            }
            completion(nil, nil, nil, error);
            return;
        }
        
        if (!data) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kNetworkError
                                             userInfo:nil];
            completion(nil, nil, nil, error);
            return;
        }
        
        NSError *localError = nil;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
        if (localError) {
            completion(nil, nil, nil, localError);
            return;
        }
        if (![(NSString *)[parsedObject objectForKey:@"stat"] isEqualToString:@"ok"]) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kServerError
                                             userInfo:nil];
            completion(nil, nil, nil, error);
            return;
        }
        
        NSDictionary *personProfile = [parsedObject objectForKey:@"person"];
        
        NSNumber *iconFarmValue = (NSNumber *)[personProfile objectForKey:@"iconfarm"];
        NSInteger iconFarm = 0;
        if (iconFarmValue) iconFarm = iconFarmValue.integerValue;
        NSString *iconServer = (NSString *)[personProfile objectForKey:@"iconserver"];
        NSURL *avatarURL = [ImageURLBuilder buddyIconURLFromIconFarm:iconFarm
                                                          iconServer:iconServer
                                                                nsid:AccountManager.userNSID];
        
        NSString *name = (NSString *)[[personProfile objectForKey:@"realname"]
                                      objectForKey:@"_content"];
        
        NSString *photosCount = (NSString *)[[[personProfile objectForKey:@"photos"]
                                              objectForKey:@"count"]
                                              objectForKey:@"_content"];
        
        completion(avatarURL, name, photosCount, nil);
    }] resume];
}

#pragma mark - Network related
- (NSURLRequest *)_userProfileURLRequest {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:kConsumerKey forKey:@"api_key"];
    [params setObject:kUserProfileMethod forKey:@"method"];
    [params setObject:AccountManager.userNSID forKey:@"user_id"];
    [params setObject:kIsNoJSONCallback forKey:@"nojsoncallback"];
    [params setObject:kResponseFormat forKey:@"format"];
    [params setObject:kResultsPerPage forKey:@"per_page"];
    
    NSURLRequest *request = [OAuth URLRequestForPath:@"/"
                                       GETParameters:params
                                              scheme:@"https"
                                                host:kAPIEndpoint
                                         consumerKey:kConsumerKey
                                      consumerSecret:nil
                                         accessToken:nil
                                         tokenSecret:nil];
    return request;

}





@end
