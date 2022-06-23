//
//  ImageURLBuilder.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 23/06/2022.
//

#import "ImageURLBuilder.h"

@implementation ImageURLBuilder

+ (NSURL *)photoURLFromServerID:(NSString *)serverID
                        photoID:(NSString *)photoID
                         secret:(NSString *)secret
                     sizeSuffix:(NSString *)sizeSuffix {
    NSString *URLString = [NSString stringWithFormat:@"https://live.staticflickr.com/%@/%@_%@_%@.jpg",
                           serverID,
                           photoID,
                           secret,
                           sizeSuffix];;
    return [NSURL URLWithString:URLString];
}

+ (NSURL *)buddyIconURLFromIconFarm:(NSInteger)iconFarm
                         iconServer:(NSString *)iconServer
                               nsid:(NSString *)nsid {
    NSString *iconURLString = ([iconServer isEqualToString:@"0"]) ?
                                @"https://www.flickr.com/images/buddyicon.gif" :
                                [NSString stringWithFormat:@"http://farm%lu.staticflickr.com/%@/buddyicons/%@.jpg",
                                 (long)iconFarm,
                                 iconServer,
                                 nsid];
    return [NSURL URLWithString:iconURLString];
}


@end
