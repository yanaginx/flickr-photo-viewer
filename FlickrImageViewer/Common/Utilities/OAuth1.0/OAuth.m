//
//  OAuth.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 21/06/2022.
//

/*
 Copyright 2011 TweetDeck Inc. All rights reserved.
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 THIS SOFTWARE IS PROVIDED BY TWEETDECK INC. ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL TWEETDECK INC. OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 The views and conclusions contained in the software and documentation are
 those of the authors and should not be interpreted as representing official
 policies, either expressed or implied, of TweetDeck Inc.
*/


#import "OAuth.h"
#import <CommonCrypto/CommonHMAC.h>
#import "UserAgent/UserAgent.h"

#define PCEN(s) \
      ([[s description] stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@"^!*'();:@&=+$,/?%#[]{}\"`<>\\| "] invertedSet]])

#define Chomp(s) { \
    const NSUInteger length = [s length]; \
    if (length > 0) \
        [s deleteCharactersInRange:NSMakeRange(length - 1, 1)]; \
}

#ifndef OAuthURLRequestTimeout
#define OAuthURLRequestTimeout 30.0
#endif

#define kPostBoundary @"---------------------------14737809831466499882746641449"

static int OAuthUTCTimeOffset = 0;

static NSString* nonce() {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef s = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge_transfer NSString *)s;
}

static NSString* timestamp() {
    time_t t;
    time(&t);
    mktime(gmtime(&t));
    return [NSString stringWithFormat:@"%ld", t + OAuthUTCTimeOffset];
}



@implementation OAuth {
    NSURL *url;
    NSString *signature_secret;
    OAuthSignatureMethod signature_method;
    NSDictionary *oauthParams; // these are pre-percent encoded
    NSDictionary *params;     // these are pre-percent encoded
    NSString *method;
    NSString *hostAndPathWithoutQuery; // we keep this because NSURL drops trailing slashes and the port number
}

- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret
              accessToken:(NSString *)accessToken
              tokenSecret:(NSString *)tokenSecret
          signatureMethod:(OAuthSignatureMethod)signatureMethod {
    NSString *smString;
    if (signatureMethod == OAuthSignatureMethodHmacSha256) {
        smString = @"HMAC-SHA256";
    } else if (signatureMethod == OAuthSignatureMethodHmacSha1) {
        smString = @"HMAC-SHA1";
    } else {
        self = nil;
        return self;
    }
    signature_method = signatureMethod;

    oauthParams = [NSDictionary dictionaryWithObjectsAndKeys:
                  consumerKey,  @"oauth_consumer_key",
                  nonce(),      @"oauth_nonce",
                  timestamp(),  @"oauth_timestamp",
                  @"1.0",       @"oauth_version",
                  smString,     @"oauth_signature_method",
                  accessToken,  @"oauth_token",
                  // LEAVE accessToken last or you'll break XAuth attempts
                  nil];
    signature_secret = [NSString stringWithFormat:@"%@&%@", consumerSecret, tokenSecret ?: @""];
    return self;
}

- (NSString *)signature_base {
    NSMutableDictionary *sigParams = [params mutableCopy];
    [sigParams addEntriesFromDictionary:oauthParams];

    NSMutableString *p3 = [NSMutableString stringWithCapacity:256];
    NSArray *keys = [[sigParams allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in keys)
    {
        //[p3 appendString:TDPCEN(key)];
        [p3 appendString:key];
        [p3 appendString:@"="];
        [p3 appendString:[sigParams[key] description]];
        [p3 appendString:@"&"];
    }
    Chomp(p3);

    return [NSString stringWithFormat:@"%@&%@%%3A%%2F%%2F%@&%@",
            method,
            url.scheme.lowercaseString,
            PCEN(hostAndPathWithoutQuery),
            PCEN(p3)];
}

- (NSString *)signature {
    NSData *sigbase = [[self signature_base] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *secret = [signature_secret dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableData *digest;
    NSString *result;
    if (signature_method == OAuthSignatureMethodHmacSha256) {
        digest = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
        CCHmac(kCCHmacAlgSHA256, secret.bytes, secret.length, sigbase.bytes, sigbase.length, digest.mutableBytes);
    } else { // assume OAuthSignatureMethodHmacSha1
        digest = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
        CCHmac(kCCHmacAlgSHA1, secret.bytes, secret.length, sigbase.bytes, sigbase.length, digest.mutableBytes);
    }
    result = [digest base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength];
    return result;
}


- (NSString *)authorizationHeader {
    NSMutableString *header = [NSMutableString stringWithCapacity:512];
    [header appendString:@"OAuth "];
    for (NSString *key in oauthParams.allKeys) {
        [header appendString:[key description]];
        [header appendString:@"=\""];
        [header appendString:[oauthParams[key] description]];
        [header appendString:@"\", "];
    }
    [header appendString:@"oauth_signature=\""];
    [header appendString:PCEN(self.signature)];
    [header appendString:@"\""];
    return header;
}

- (NSMutableURLRequest *)requestWithHeaderValues:(NSDictionary *)headerValues {
    NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:url
                                                      cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                  timeoutInterval:OAuthURLRequestTimeout];
    [rq setValue:UserAgent() forHTTPHeaderField:@"User-Agent"];
    [rq setValue:[self authorizationHeader] forHTTPHeaderField:@"Authorization"];
    [rq setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    if (headerValues) {
        for (NSString* key in headerValues) {
            id value = [headerValues objectForKey:key];
            if ([value isKindOfClass:[NSString class]]) {
                [rq setValue:value forHTTPHeaderField:key];
            }
        }
    }
    [rq setHTTPMethod:method];
    return rq;
}

// unencodedParameters are encoded and assigned to self->params, returns encoded queryString
- (id)setParameters:(NSDictionary *)unencodedParameters {
    NSMutableString *queryString = [NSMutableString string];
    NSMutableDictionary *encodedParameters = [NSMutableDictionary new];
    for (NSString *key in unencodedParameters.allKeys)
    {
        NSString *enkey = PCEN(key);
        NSString *envalue = PCEN(unencodedParameters[key]);
        encodedParameters[enkey] = envalue;
        [queryString appendString:enkey];
        [queryString appendString:@"="];
        [queryString appendString:envalue];
        [queryString appendString:@"&"];
    }
    Chomp(queryString);
    params = [encodedParameters copy];
    return queryString;
}

+ (NSURLRequest *)URLRequestForPath:(NSString *)unencodedPathWithoutQuery
                      GETParameters:(NSDictionary *)unencodedParameters
                               host:(NSString *)host
                        consumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                        tokenSecret:(NSString *)tokenSecret {
    
    return [OAuth URLRequestForPath:unencodedPathWithoutQuery
                         parameters:unencodedParameters
                               host:host
                        consumerKey:consumerKey
                     consumerSecret:consumerSecret
                        accessToken:accessToken
                        tokenSecret:tokenSecret
                             scheme:@"http"
                      requestMethod:@"GET"
                       dataEncoding:OAuthContentTypeUrlEncodedForm
                       headerValues:nil
                    signatureMethod:OAuthSignatureMethodHmacSha1];
}


+ (NSURLRequest *)URLRequestForPath:(NSString *)unencodedPathWithoutQuery
                         parameters:(NSDictionary *)unencodedParameters
                               host:(NSString *)host
                        consumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                        tokenSecret:(NSString *)tokenSecret
                             scheme:(NSString *)scheme
                      requestMethod:(NSString *)method
                       dataEncoding:(OAuthContentType)dataEncoding
                       headerValues:(NSDictionary *)headerValues
                    signatureMethod:(OAuthSignatureMethod)signatureMethod {
    if (!host || !unencodedPathWithoutQuery || !scheme || !method)
        return nil;

    OAuth *oauth = [[OAuth alloc] initWithConsumerKey:consumerKey
                                       consumerSecret:consumerSecret
                                          accessToken:accessToken
                                          tokenSecret:tokenSecret
                                      signatureMethod:signatureMethod];
    if (!oauth) // This would happen with someone slipping in an unsupported signature method
        return nil;

    // We don't use pcen as we don't want to percent encode eg. /, this is perhaps
    // not the most all encompassing solution, but in practice it seems to work
    // everywhere and means that programmer error is *much* less likely.
//    NSString *encodedPathWithoutQuery = [unencodedPathWithoutQuery stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedPathWithoutQuery = [unencodedPathWithoutQuery stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLPathAllowedCharacterSet];

    oauth->method = method;
    oauth->hostAndPathWithoutQuery = [host.lowercaseString stringByAppendingString:encodedPathWithoutQuery];

    NSMutableURLRequest *rq;
    if ([method isEqualToString:@"GET"] || [method isEqualToString:@"DELETE"] || [method isEqualToString:@"HEAD"] || (([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"]) && dataEncoding == OAuthContentTypeUrlEncodedQuery)) {
        id path = [oauth setParameters:unencodedParameters];
        if (path && unencodedParameters) {
            [path insertString:@"?" atIndex:0];
            [path insertString:encodedPathWithoutQuery atIndex:0];
        } else {
            path = encodedPathWithoutQuery;
        }

        oauth->url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@://%@%@",
                                                    scheme, host, path]];
        rq = [oauth requestWithHeaderValues:headerValues];
    }
    else {
        oauth->url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@://%@%@",
                                                    scheme, host, encodedPathWithoutQuery]];
        if ((dataEncoding == OAuthContentTypeUrlEncodedForm) || (unencodedParameters == nil)) {
            NSMutableString *postbody = [oauth setParameters:unencodedParameters];
            rq = [oauth requestWithHeaderValues:headerValues];

            if (postbody.length) {
                [rq setHTTPBody:[postbody dataUsingEncoding:NSUTF8StringEncoding]];
                [rq setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                [rq setValue:[NSString stringWithFormat:@"%lu", (unsigned long)rq.HTTPBody.length] forHTTPHeaderField:@"Content-Length"];
            }
        }
        else if (dataEncoding == OAuthContentTypeJsonObject) {
            NSError *error;
            NSData *postbody = [NSJSONSerialization dataWithJSONObject:unencodedParameters options:0 error:&error];
            if (error || !postbody) {
                NSLog(@"Got an error encoding JSON: %@", error);
            } else {
                [oauth setParameters:@{}]; // empty dictionary populates variables without putting data into the signature_base
                rq = [oauth requestWithHeaderValues:headerValues];

                if (postbody.length) {
                    [rq setHTTPBody:postbody];
                    [rq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    [rq setValue:[NSString stringWithFormat:@"%lu", (unsigned long)rq.HTTPBody.length] forHTTPHeaderField:@"Content-Length"];
                }
            }
        }
        // invalid type
        else {
            oauth = nil;
            rq = nil;
        }
    }

    return rq;
}

+ (NSURLRequest *)URLRequestForPath:(NSString *)unencodedPathWithoutQuery
                      GETParameters:(NSDictionary *)unencodedParameters
                             scheme:(NSString *)scheme
                               host:(NSString *)host
                        consumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                        tokenSecret:(NSString *)tokenSecret; {
    return [OAuth URLRequestForPath:unencodedPathWithoutQuery
                         parameters:unencodedParameters
                               host:host
                        consumerKey:consumerKey
                     consumerSecret:consumerSecret
                        accessToken:accessToken
                        tokenSecret:tokenSecret
                             scheme:scheme
                      requestMethod:@"GET"
                       dataEncoding:OAuthContentTypeUrlEncodedForm
                       headerValues:nil
                    signatureMethod:OAuthSignatureMethodHmacSha1];
}

+ (NSURLRequest *)URLRequestForPath:(NSString *)unencodedPath
                     POSTParameters:(NSDictionary *)unencodedParameters
                               host:(NSString *)host
                        consumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                        tokenSecret:(NSString *)tokenSecret {
    return [OAuth URLRequestForPath:unencodedPath
                         parameters:unencodedParameters
                               host:host
                        consumerKey:consumerKey
                     consumerSecret:consumerSecret
                        accessToken:accessToken
                        tokenSecret:tokenSecret
                             scheme:@"https"
                      requestMethod:@"POST"
                       dataEncoding:OAuthContentTypeUrlEncodedForm
                       headerValues:nil
                    signatureMethod:OAuthSignatureMethodHmacSha1];
}


+ (NSURLRequest *)URLRequestUsingQueryAndMultipartFormDataForPath:(NSString *)unencodedPath
                                                   POSTParameters:(NSDictionary *)unencodedParameters
                                                             host:(NSString *)host
                                                      consumerKey:(NSString *)consumerKey
                                                   consumerSecret:(NSString *)consumerSecret
                                                      accessToken:(NSString *)accessToken
                                                      tokenSecret:(NSString *)tokenSecret {
    NSMutableURLRequest *requestWithSignature = [[OAuth URLRequestForPath:unencodedPath
                                                               parameters:unencodedParameters
                                                                     host:host
                                                              consumerKey:consumerKey
                                                           consumerSecret:consumerSecret
                                                              accessToken:accessToken
                                                              tokenSecret:tokenSecret
                                                                   scheme:@"https"
                                                            requestMethod:@"POST"
                                                             dataEncoding:OAuthContentTypeUrlEncodedQuery
                                                             headerValues:nil
                                                          signatureMethod:OAuthSignatureMethodHmacSha1] mutableCopy];
    NSString *boundary = kPostBoundary;
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [requestWithSignature addValue:contentType
                forHTTPHeaderField: @"Content-Type"];
    return requestWithSignature;
}

+ (NSURLRequest *)URLRequestUsingQueryForPath:(NSString *)unencodedPath_WITHOUT_Query
                                GETParameters:(NSDictionary *)unencodedParameters
                                         host:(NSString *)host
                                  consumerKey:(NSString *)consumerKey
                               consumerSecret:(NSString *)consumerSecret
                                  accessToken:(NSString *)accessToken
                                  tokenSecret:(NSString *)tokenSecret {
    return [OAuth URLRequestForPath:unencodedPath_WITHOUT_Query
                         parameters:unencodedParameters
                               host:host
                        consumerKey:consumerKey
                     consumerSecret:consumerSecret
                        accessToken:accessToken
                        tokenSecret:tokenSecret
                             scheme:@"https"
                      requestMethod:@"GET"
                       dataEncoding:OAuthContentTypeUrlEncodedQuery
                       headerValues:nil
                    signatureMethod:OAuthSignatureMethodHmacSha1];
}

+ (int)utcTimeOffset {
    return OAuthUTCTimeOffset;
}

+ (void)setUtcTimeOffset:(int)offset {
    OAuthUTCTimeOffset = offset;
}


+ (void)appendToPOSTBody:(NSMutableData *)postBodyData
                    name:(NSString *)name
                   value:(NSString *)value {
    [postBodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", kPostBoundary]
                              dataUsingEncoding:NSUTF8StringEncoding]];
    [postBodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", name]
                              dataUsingEncoding:NSUTF8StringEncoding]];
    [postBodyData appendData:[[NSString stringWithFormat:@"%@\r\n", value] dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (void)appendToPOSTBody:(NSMutableData *)postBodyData
                    name:(NSString *)name
                fileName:(NSString *)fileName
                    data:(NSData *)data {
    [postBodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", kPostBoundary]
                              dataUsingEncoding:NSUTF8StringEncoding]];
    [postBodyData appendData:[[NSString stringWithFormat:
                               @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",
                               name,
                               fileName]
                              dataUsingEncoding:NSUTF8StringEncoding]];
    [postBodyData appendData:[[NSString stringWithFormat:@"\r\n"]
                              dataUsingEncoding:NSUTF8StringEncoding]];
    [postBodyData appendData:data];
}

+ (void)appendEndOfMultipartFormDataToPOSTBody:(NSMutableData *)postBodyData {
    [postBodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", kPostBoundary]
                              dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
