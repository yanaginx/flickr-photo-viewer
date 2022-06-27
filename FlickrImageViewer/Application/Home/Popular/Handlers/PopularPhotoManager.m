//
//  PopularPhotoManager.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 27/06/2022.
//

#import "PopularPhotoManager.h"
#import "../DataModel/Photo.h"
#import "../../../../Common/Utilities/OAuth1.0/OAuth.h"
#import "../../../../Common/Constants/Constants.h"

@implementation PopularPhotoManager

static NSString *oauthConsumerKey = kConsumerKey;
static NSString *endpoint = kEndpoint;
static NSString *userID = kPopularUserID;
static NSString *method = @"flickr.photos.getPopular";
static NSString *isNoJSONCallback = @"1";
static NSString *format = @"json";

+ (instancetype)sharedPopularPhotoManager {
    static dispatch_once_t onceToken;
    static PopularPhotoManager *shared;
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

- (void)getPopularPhotoWithCompletionHandler:(void (^)(NSMutableArray<Photo *> * _Nullable,
                                                       NSError * _Nullable))completion {
    NSURLRequest *request = [self popularPhotoURLRequest];
    [[[NSURLSession sharedSession]
      dataTaskWithRequest:request
      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        if (!data) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:PopularPhotoManagerErrorNetworkError
                                             userInfo:nil];
            completion(nil, error);
        }
        NSString *responseDataString = [[NSString alloc] initWithData:data
                                                             encoding:NSASCIIStringEncoding];
        NSLog(@"[DEBUG] %s : response string: %@", __func__, responseDataString);
        completion(nil, nil);
    }] resume];
}

#pragma mark - Network related
- (NSURLRequest *)popularPhotoURLRequest {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:oauthConsumerKey forKey:@"api_key"];
    [params setObject:method forKey:@"method"];
    [params setObject:userID forKey:@"user_id"];
    [params setObject:isNoJSONCallback forKey:@"nojsoncallback"];
    [params setObject:format forKey:@"format"];
    
        
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
