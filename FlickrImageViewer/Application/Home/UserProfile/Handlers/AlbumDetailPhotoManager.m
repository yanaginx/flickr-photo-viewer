//
//  AlbumDetailPhotoManager.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 04/07/2022.
//

#import "AlbumDetailPhotoManager.h"
#import "../../../../Models/Photo.h"

#import "../../../Login/Handlers/LoginHandler.h"
#import "../../../../Common/Utilities/OAuth1.0/OAuth.h"
#import "../../../../Common/Utilities/ImageURLBuilder/ImageURLBuilder.h"
#import "../../../../Common/Utilities/AccountManager/AccountManager.h"
#import "../../../../Common/Constants/Constants.h"

@implementation AlbumDetailPhotoManager

#pragma mark - Make request

- (void)getAlbumDetailPhotosForAlbumID:(NSString *)albumID
                                  page:(NSInteger)pageNum
                     completionHandler:(void (^)(NSMutableArray<Photo *> * _Nullable,
                                                 NSError * _Nullable))completion {
    NSURLRequest *request = [self albumDetailPhotosURLRequestWithAlbumID:albumID
                                                                 pageNum:pageNum];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data,
                                                         NSURLResponse *response,
                                                         NSError *error) {
        if (error) {
            NSLog(@"[DEBUG] error: %@", error.localizedDescription);
            if ([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."] ||
                [error.localizedDescription isEqualToString:@"The request timed out."]) {
                error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                            code:kNetworkError
                                        userInfo:nil];
            }
            completion(nil, error);
            return;
        }
        
        if (!data) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kNetworkError
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
        if (![(NSString *)[parsedObject objectForKey:@"stat"] isEqualToString:@"ok"] ||
            [[parsedObject objectForKey:@"photoset"] objectForKey:@"photo"] == nil) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kServerError
                                             userInfo:nil];
            completion(nil, error);
            return;
        }
        
        NSArray *photoObjects = [[parsedObject objectForKey:@"photoset"] objectForKey:@"photo"];
        if (photoObjects.count == 0 && pageNum == 1) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kNoDataError
                                             userInfo:nil];
            completion(nil, error);
            return;
        }
        
        NSMutableArray *photos = [NSMutableArray array];
        for (NSDictionary *photoObject in photoObjects) {
            NSString *photoID = (NSString *)[photoObject objectForKey:@"id"];
            NSString *photoSecret = (NSString *)[photoObject objectForKey:@"secret"];
            NSString *photoServer = (NSString *)[photoObject objectForKey:@"server"];
            NSURL *photoURL = [ImageURLBuilder photoURLFromServerID:photoServer
                                                            photoID:photoID
                                                             secret:photoSecret
                                                         sizeSuffix:nil];
            
            NSNumber *heightFetched = (NSNumber *)[photoObject objectForKey:@"height_t"];
            NSNumber *widthFetched = (NSNumber *)[photoObject objectForKey:@"width_t"];
            CGFloat aspectRatio = heightFetched.floatValue / widthFetched.floatValue;
            CGFloat height_m = 0;
            CGFloat width_m = 0;
            if (heightFetched.longValue == 100) {
                height_m = 500;
                width_m = height_m / aspectRatio;
            } else if (widthFetched.longValue == 100) {
                width_m = 500;
                height_m = width_m * aspectRatio;
            }
            CGSize imageSize = CGSizeMake(width_m, height_m);
            
            Photo *photo = [[Photo alloc] initWithImageURL:photoURL
                                                 imageSize:imageSize];
            [photos addObject:photo];
        }
        completion(photos, nil);
        
    }] resume];
}


#pragma mark - Network related
- (NSURLRequest *)albumDetailPhotosURLRequestWithAlbumID:(NSString *)albumID
                                                 pageNum:(NSInteger)pageNum {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:kConsumerKey forKey:@"api_key"];
    [params setObject:kGetAlbumDetailPhotosMethod forKey:@"method"];
    [params setObject:AccountManager.userNSID forKey:@"user_id"];
    [params setObject:kIsNoJSONCallback forKey:@"nojsoncallback"];
    [params setObject:kResponseFormat forKey:@"format"];
    [params setObject:kResultsPerPage forKey:@"per_page"];
    [params setObject:albumID forKey:@"photoset_id"];
    [params setObject:@"url_t" forKey:@"extras"];
    
    [params setObject:@"1" forKey:@"privacy_filter"];
    
    NSString *page = [NSString stringWithFormat:@"%ld", pageNum];
    [params setObject:page forKey:@"page"];
    
        
    NSURLRequest *request = [OAuth URLRequestForPath:@"/"
                                       GETParameters:params
                                              scheme:@"https"
                                                host:kAPIEndpoint
                                         consumerKey:kConsumerKey
                                      consumerSecret:kConsumerSecret
                                         accessToken:AccountManager.userAccessToken
                                         tokenSecret:AccountManager.userSecretToken];
    return request;
}


@end
