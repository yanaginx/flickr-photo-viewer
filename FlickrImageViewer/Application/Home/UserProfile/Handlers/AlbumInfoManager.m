//
//  AlbumInfoManager.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 04/07/2022.
//

#import "AlbumInfoManager.h"
#import "../../../../Models/AlbumInfo.h"
#import "../../../../Models/CoreData/Album+CoreDataClass.h"
#import "../../../../Models/CoreData/Album+CoreDataProperties.h"

#import "../../../../Common/Utilities/OAuth1.0/OAuth.h"
#import "../../../../Common/Utilities/ImageURLBuilder/ImageURLBuilder.h"
#import "../../../../Common/Utilities/AccountManager/AccountManager.h"
#import "../../../../Common/Utilities/Reachability/Reachability.h"
#import "../../../../Common/Utilities/DataController/DataController.h"
#import "../../../../Common/Constants/Constants.h"

@interface AlbumInfoManager () {
    BOOL isOfflineFetched;
}

@property (nonatomic, strong) DataController *dataController;

@end

@implementation AlbumInfoManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataController = [[DataController alloc] initWithModelName:kModelName];
        [self.dataController loadWithCompletionHandler:^{
            NSLog(@"[INFO] %s: Container loaded!", __func__);
        }];
    }
    return self;
}

- (void)getUserAlbumInfosWithPage:(NSInteger)pageNum
                completionHandler:(void (^)(NSMutableArray<AlbumInfo *> * _Nullable,
                                            NSError * _Nullable))completion {
    if (![self _isConnected]) {
        // if fetched offline data then just return an empty array
        if (isOfflineFetched) {
            completion([NSMutableArray array], nil);
            return;
        }
        // TODO: Fetch from core data first
        NSArray *albums = [self _fetchAlbumInfoFromLocal];
        // if there is data then transform it into the model then return
        if (albums) {
            NSMutableArray *albumInfos = [self _extractAlbumInfosFromAlbums:albums];
             // Printing all the photo fetched!
            for (AlbumInfo *albumInfo in albumInfos) {
                NSLog(@"[DEBUG] %s: albumID fetched offline: %@",
                      __func__,
                      albumInfo.albumID);
            }
            // END - printing all the photo fetched!
            isOfflineFetched = YES;
            completion(albumInfos, nil);
            return;
        }
        // If there is no offline data then return the no internet error
        NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                             code:kNetworkError
                                         userInfo:nil];
        completion(nil, error);
        return;
    }

    // else make the request as usual
    isOfflineFetched = NO;
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
            // Save the album info into the core data
            BOOL isSaveToCoreDataSuccessful = [self _saveAlbumInfoWithAlbumInfo:albumInfo];
            if (!isSaveToCoreDataSuccessful) {
                NSLog(@"[DEBUG] %s: Something went wrong!", __func__);
            }
        }
        completion(photoSets, nil);
    }] resume];
   
}

#pragma mark - Private methods
- (BOOL)_isConnected {
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    if (reach.currentReachabilityStatus != NotReachable) {
        NSLog(@"[DEBUG] %s: Is Connected", __func__);
        return YES;
    }
    NSLog(@"[DEBUG] %s: Not connected", __func__);
    return NO;
}

- (NSArray *)_fetchAlbumInfoFromLocal {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Album"];
    NSError *error = nil;
    NSArray *results = [self.dataController.backgroundContext executeFetchRequest:request
                                                                            error:&error];
    if (!results && error) {
        NSLog(@"[ERROR] Error fetching AlbumInfo objects: %@\n%@",
              [error localizedDescription],
              [error userInfo]);
        return nil;
    }
    for (Album *albumInfo in results) {
        NSLog(@"[DEBUG] %s: fetched result with album ID: %@",
              __func__,
              albumInfo.albumID);
    }
    return results;
}

- (BOOL)_saveAlbumInfoWithAlbumInfo:(AlbumInfo *)albumInfo {
    Album *album = [NSEntityDescription
                   insertNewObjectForEntityForName:@"Album"
                   inManagedObjectContext:self.dataController.backgroundContext];
    album.albumID = albumInfo.albumID;
    album.creatationDate = albumInfo.dateCreated;
    album.albumImageURL = albumInfo.albumImageURL.absoluteString;
    album.numbersOfPhoto = albumInfo.numberOfPhotos;
    album.albumName = albumInfo.albumName;
    // save the context
    NSError *error = nil;
    if ([self.dataController.backgroundContext save:&error] == NO) {
        NSLog(@"Error saving context: %@\n%@",
              error.localizedDescription,
              error.userInfo);
        return NO;
    }
    return YES;
}

- (NSMutableArray *)_extractAlbumInfosFromAlbums:(NSArray *)albums {
    NSMutableArray *albumInfos = [NSMutableArray array];
    // Convert core data data into model
    for (Album *album in albums) {
        NSURL *albumImageURL = [NSURL URLWithString:album.albumImageURL];
        AlbumInfo *albumInfo = [[AlbumInfo alloc] initWithAlbumID:album.albumID
                                                         imageURL:albumImageURL
                                                        albumName:album.albumName
                                                      dateCreated:album.creatationDate
                                                   numberOfPhotos:album.numbersOfPhoto];
        [albumInfos addObject:albumInfo];
    }
    return albumInfos;
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
