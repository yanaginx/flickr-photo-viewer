//
//  PopularPhotoManager.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 27/06/2022.
//

#import "PopularPhotoManager.h"
#import "../DataModel/Photo.h"
#import "../../../../Common/Utilities/OAuth1.0/OAuth.h"
#import "../../../../Common/Utilities/ImageURLBuilder/ImageURLBuilder.h"
#import "../../../../Common/Constants/Constants.h"

@implementation PopularPhotoManager

static NSString *oauthConsumerKey = kConsumerKey;
static NSString *endpoint = kEndpoint;
static NSString *userID = kPopularUserID;
static NSString *method = @"flickr.photos.getPopular";
static NSString *isNoJSONCallback = @"1";
static NSString *format = @"json";
static NSString *perPage = @"20";

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

- (void)getPopularPhotoURLsWithPage:(NSInteger)pageNum
                  completionHandler:(void (^)(NSMutableArray<NSURL *> * _Nullable,
                                          NSError * _Nullable))completion {
    
    NSURLRequest *request = [self popularPhotoURLRequestWithPageNum:pageNum];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if ([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."]) {
                error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                            code:PopularPhotoManagerErrorNetworkError
                                        userInfo:nil];
            }
            completion(nil, error);
            return;
        }
        
        if (!data) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:PopularPhotoManagerErrorNetworkError
                                             userInfo:nil];
            completion(nil, error);
            return;
        }
        
        NSError *localError = nil;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
        if (localError) {
            completion(nil, localError);
            return;
        }
        if (![(NSString *)[parsedObject objectForKey:@"stat"] isEqualToString:@"ok"]) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:PopularPhotoManagerErrorNotValidData
                                             userInfo:nil];
            completion(nil, error);
            return;
        }
        
        NSArray *photos = [[parsedObject objectForKey:@"photos"] objectForKey:@"photo"];
        NSMutableArray *photoURLs = [NSMutableArray array];
        for (NSDictionary *photoObject in photos) {
            NSString *photoID = (NSString *)[photoObject objectForKey:@"id"];
            NSString *photoSecret = (NSString *)[photoObject objectForKey:@"secret"];
            NSString *photoServer = (NSString *)[photoObject objectForKey:@"server"];
            NSURL *photoURL = [ImageURLBuilder photoURLFromServerID:photoServer
                                                            photoID:photoID
                                                             secret:photoSecret
                                                         sizeSuffix:nil];
            [photoURLs addObject:photoURL];
        }
        completion(photoURLs, nil);
        
    }] resume];
}

#pragma mark - Network related
- (NSURLRequest *)popularPhotoURLRequestWithPageNum:(NSInteger)pageNum {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:oauthConsumerKey forKey:@"api_key"];
    [params setObject:method forKey:@"method"];
    [params setObject:userID forKey:@"user_id"];
    [params setObject:isNoJSONCallback forKey:@"nojsoncallback"];
    [params setObject:format forKey:@"format"];
    [params setObject:perPage forKey:@"per_page"];
    
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
