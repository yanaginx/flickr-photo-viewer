//
//  HMAC-sha1.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import "HMAC-sha1.h"

@implementation HMAC_sha1

- (NSData *)hmacForKeyAndData:(NSString *)key data:(NSString *)url {
        const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
        const char *cData = [url cStringUsingEncoding:NSASCIIStringEncoding];
        unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
        CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
        return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
}

@end
