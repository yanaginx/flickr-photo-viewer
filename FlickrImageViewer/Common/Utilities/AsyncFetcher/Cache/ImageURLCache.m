//
//  ImageURLCache.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 19/07/2022.
//

#import "ImageURLCache.h"

@implementation ImageURLCache

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    NSCachedURLResponse *cachedResponse = [super cachedResponseForRequest:request];

    if (cachedResponse != nil &&
        [cachedResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *originalResponse = (NSHTTPURLResponse *)[cachedResponse response];
        NSHTTPURLResponse *alteredResponse = nil;
        NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:[originalResponse allHeaderFields]];

        [headers removeObjectForKey:@"Cache-Control"];
        [headers removeObjectForKey:@"Vary"];
        [headers setObject:@"Thu, 01 Dec 2050 16:00:00 GMT" forKey:@"Expires"];
        alteredResponse = [[NSHTTPURLResponse alloc] initWithURL:[originalResponse URL]
                                                      statusCode:[originalResponse statusCode]
                                                     HTTPVersion:@"HTTP/1.1"
                                                    headerFields:headers];
        cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:alteredResponse
                                                                  data:[cachedResponse data]
                                                              userInfo:[cachedResponse userInfo]
                                                         storagePolicy:[cachedResponse storagePolicy]];
    }

    return cachedResponse;
}

@end
