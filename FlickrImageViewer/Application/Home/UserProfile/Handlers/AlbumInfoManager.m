//
//  AlbumInfoManager.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 04/07/2022.
//

#import "AlbumInfoManager.h"
#import "../../../../Models/AlbumInfo.h"
#import "../../../../Common/Utilities/OAuth1.0/OAuth.h"
#import "../../../../Common/Utilities/ImageURLBuilder/ImageURLBuilder.h"
#import "../../../../Common/Utilities/AccountManager/AccountManager.h"
#import "../../../../Common/Constants/Constants.h"

@implementation AlbumInfoManager
- (void)getUserAlbumInfosWithPage:(NSInteger)pageNum
                completionHandler:(void (^)(NSMutableArray<AlbumInfo *> * _Nullable,
                                            NSError * _Nullable))completion {
    NSURLRequest *request = [self _albumInfoURLRequestWithPageNum:pageNum];
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
        if (![(NSString *)[parsedObject objectForKey:@"stat"] isEqualToString:@"ok"]) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kServerError
                                             userInfo:nil];
            completion(nil, error);
            return;
        }
        
        NSArray *photoSetObjects = [[parsedObject objectForKey:@"photosets"] objectForKey:@"photoset"];
        if (photoSetObjects.count == 0 &&
            pageNum == 1) {
            NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                 code:kNoDataError
                                             userInfo:nil];
            completion(nil, error);
            return;
        }
        
        NSMutableArray *photoSets = [NSMutableArray array];
        for (NSDictionary *photoSetObject in photoSetObjects) {
            NSString *albumCoverID = (NSString *)[photoSetObject objectForKey:@"primary"];
            NSString *albumCoverSecret = (NSString *)[photoSetObject objectForKey:@"secret"];
            NSString *albumCoverServer = (NSString *)[photoSetObject objectForKey:@"server"];
            NSURL *albumCoverURL = [ImageURLBuilder photoURLFromServerID:albumCoverServer
                                                                 photoID:albumCoverID
                                                                  secret:albumCoverSecret
                                                              sizeSuffix:nil];
            NSString *albumID = [photoSetObject objectForKey:@"id"];
            NSString *albumName = (NSString *)[[photoSetObject objectForKey:@"title"]
                                   objectForKey:@"_content"];
            NSNumber *numberOfPhotosNumber = (NSNumber *)[photoSetObject objectForKey:@"count_photos"];
            NSInteger numberOfPhotos = [numberOfPhotosNumber integerValue];
            NSString *dateCreatedString = (NSString *)[photoSetObject objectForKey:@"date_create"];
            NSTimeInterval dateCreatedSince1970 = [dateCreatedString floatValue];
            NSDate *dateCreated = [NSDate dateWithTimeIntervalSince1970:dateCreatedSince1970];
            
            AlbumInfo *albumInfo = [[AlbumInfo alloc] initWithAlbumID:albumID
                                                             imageURL:albumCoverURL
                                                            albumName:albumName
                                                          dateCreated:dateCreated
                                                       numberOfPhotos:numberOfPhotos];
            [photoSets addObject:albumInfo];
        }
        completion(photoSets, nil);
    }] resume];
   
}

#pragma mark - Network related
- (NSURLRequest *)_albumInfoURLRequestWithPageNum:(NSInteger)pageNum {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:kConsumerKey forKey:@"api_key"];
    [params setObject:kGetAlbumInfosMethod forKey:@"method"];
    [params setObject:AccountManager.userNSID forKey:@"user_id"];
    [params setObject:kIsNoJSONCallback forKey:@"nojsoncallback"];
    [params setObject:kResponseFormat forKey:@"format"];
    [params setObject:kResultsPerPage forKey:@"per_page"];
    NSString *page = [NSString stringWithFormat:@"%ld", pageNum];
    [params setObject:page forKey:@"page"];
    
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
