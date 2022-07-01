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
#import "../../../../Common/Constants/Constants.h"

@implementation UserProfileManager

static NSString *oauthConsumerKey = kConsumerKey;
static NSString *endpoint = kEndpoint;
static NSString *publicPhotosMethod = @"flickr.people.getPublicPhotos";
static NSString *userProfileMethod = @"flickr.people.getInfo";
static NSString *isNoJSONCallback = @"1";
static NSString *format = @"json";
static NSString *perPage = @"20";

+ (instancetype)sharedUserProfileManager {
    static dispatch_once_t onceToken;
    static UserProfileManager *shared;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] initPrivate];
    });
    return shared;
}

- (instancetype)initPrivate {
    self = [super init];
    return self;
}

#pragma mark - Make request

- (void)getPublicPhotoURLsWithPage:(NSInteger)pageNum
                 completionHandler:(void (^)(NSMutableArray<Photo *> * _Nullable,
                                             NSError * _Nullable))completion {
    
}

- (void)getUserProfileWithCompletionHandler:(void (^)(NSURL * _Nullable,
                                                      NSString * _Nullable,
                                                      NSString * _Nullable,
                                                      NSError * _Nullable))completion {
    NSURLRequest *request = [self userProfileURLRequest];
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
        
//        NSLog(@"[DEBUG] %s : userNSID: %@", __func__, LoginHandler.sharedLoginHandler.userNSID);
//        NSLog(@"[DEBUG] %s : data fetched: %@", __func__, [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        
        NSError *localError = nil;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
        if (localError) {
            completion(nil, nil, nil, localError);
            return;
        }
        if (![(NSString *)[parsedObject objectForKey:@"stat"] isEqualToString:@"ok"]) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kSomeError
                                             userInfo:nil];
            completion(nil, nil, nil, error);
            return;
        }
        
        NSDictionary *personProfile = [parsedObject objectForKey:@"person"];
//        NSLog(@"[DEBUG] %s : profile fetched: %@", __func__, personProfile);
        
        NSNumber *iconFarmValue = (NSNumber *)[personProfile objectForKey:@"iconfarm"];
        NSInteger iconFarm = 0;
        if (iconFarmValue) iconFarm = iconFarmValue.integerValue;
        NSString *iconServer = (NSString *)[personProfile objectForKey:@"iconserver"];
        NSURL *avatarURL = [ImageURLBuilder buddyIconURLFromIconFarm:iconFarm
                                                          iconServer:iconServer
                                                                nsid:kUserNSID];
//        NSLog(@"[DEBUG] %s : avatar URL: %@", __func__, avatarURL.absoluteString);
        
        NSString *name = (NSString *)[[personProfile objectForKey:@"realname"]
                                      objectForKey:@"_content"];
//        NSLog(@"[DEBUG] %s : name: %@", __func__, name);
        
        NSString *photosCount = (NSString *)[[[personProfile objectForKey:@"photos"]
                                              objectForKey:@"count"]
                                              objectForKey:@"_content"];
//        NSLog(@"[DEBUG] %s : count: %@", __func__, photosCount);
        
        completion(avatarURL, name, photosCount, nil);
    }] resume];
}

#pragma mark - Network related
- (NSURLRequest *)userProfileURLRequest {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:oauthConsumerKey forKey:@"api_key"];
    [params setObject:userProfileMethod forKey:@"method"];
    [params setObject:kUserNSID forKey:@"user_id"];
    [params setObject:isNoJSONCallback forKey:@"nojsoncallback"];
    [params setObject:format forKey:@"format"];
    [params setObject:perPage forKey:@"per_page"];
    
    NSURLRequest *request = [OAuth URLRequestForPath:@"/"
                                       GETParameters:params
                                              scheme:@"https"
                                                host:endpoint
                                         consumerKey:oauthConsumerKey
                                      consumerSecret:nil
                                         accessToken:nil
                                         tokenSecret:nil];
    return request;

}


- (NSURLRequest *)publicPhotoURLRequestWithPageNum:(NSInteger)pageNum {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:oauthConsumerKey forKey:@"api_key"];
    [params setObject:publicPhotosMethod forKey:@"method"];
    [params setObject:kUserNSID forKey:@"user_id"];
    [params setObject:isNoJSONCallback forKey:@"nojsoncallback"];
    [params setObject:format forKey:@"format"];
    [params setObject:perPage forKey:@"per_page"];
    [params setObject:@"url_t" forKey:@"extras"];
    
    NSString *page = [NSString stringWithFormat:@"%ld", pageNum];
    [params setObject:page forKey:@"page"];
    
        
    NSURLRequest *request = [OAuth URLRequestForPath:@"/"
                                       GETParameters:params
                                              scheme:@"https"
                                                host:endpoint
                                         consumerKey:oauthConsumerKey
                                      consumerSecret:nil
                                         accessToken:nil
                                         tokenSecret:nil];
    return request;
}


@end
