//
//  OAuth.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 21/06/2022.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, OAuthSignatureMethod) {
    OAuthSignatureMethodHmacSha1,
    OAuthSignatureMethodHmacSha256,
};
typedef NS_ENUM(NSInteger, OAuthContentType) {
    OAuthContentTypeUrlEncodedForm,
    OAuthContentTypeJsonObject,
    OAuthContentTypeUrlEncodedQuery,
};

@interface OAuth : NSObject
/**
  @p unencodeParameters may be nil. Objects in the dictionary must be strings.
  You are contracted to consume the NSURLRequest *immediately*. Don't put the
  queryParameters in the path as a query string! Path MUST start with a slash!
  Don't percent encode anything! This will submit via HTTP. If you need HTTPS refer
  to the next selector.
*/
+ (NSURLRequest *)URLRequestForPath:(NSString *)unencodedPath_WITHOUT_Query
                      GETParameters:(NSDictionary *)unencodedParameters
                               host:(NSString *)host
                        consumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                        tokenSecret:(NSString *)tokenSecret;

/**
  Some services insist on HTTPS. Or maybe you don't want the data to be sniffed.
  You can pass @"https" via the scheme parameter.
*/
+ (NSURLRequest *)URLRequestForPath:(NSString *)unencodedPath_WITHOUT_Query
                      GETParameters:(NSDictionary *)unencodedParameters
                             scheme:(NSString *)scheme
                               host:(NSString *)host
                        consumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                        tokenSecret:(NSString *)tokenSecret;

/**
 Oauth request using query params and HTTPS
 */
+ (NSURLRequest *)URLRequestUsingQueryForPath:(NSString *)unencodedPath_WITHOUT_Query
                                GETParameters:(NSDictionary *)unencodedParameters
                                         host:(NSString *)host
                                  consumerKey:(NSString *)consumerKey
                               consumerSecret:(NSString *)consumerSecret
                                  accessToken:(NSString *)accessToken
                                  tokenSecret:(NSString *)tokenSecret;

/**
  We always POST with HTTPS. This is because at least half the time the user's
  data is at least somewhat private, but also because apparently some carriers
  mangle POST requests and break them. We saw this in France for example.
  READ THE DOCUMENTATION FOR GET AS IT APPLIES HERE TOO!
*/
+ (NSURLRequest *)URLRequestForPath:(NSString *)unencodedPath
                     POSTParameters:(NSDictionary *)unencodedParameters
                               host:(NSString *)host
                        consumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                        tokenSecret:(NSString *)tokenSecret;

/**
 Posting with image data:
 */
+ (NSURLRequest *)URLRequestForPath:(NSString *)unencodedPath
                     POSTParameters:(NSDictionary *)unencodedParameters
                               host:(NSString *)host
                        consumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                        tokenSecret:(NSString *)tokenSecret
                          imageData:(NSData *)imageData
                          imageName:(NSString *)imageName
                        description:(NSString *)imageDescription;

/**
 This method allows the caller to specify particular values for many different parameters such
 as scheme, method, header values and alternate signature hash algorithms.

 @p scheme may be any string value, generally "http" or "https".
 @p requestMethod may be any string value. There is no validation, so remember that all
 currently-defined HTTP methods are uppercase and the RFC specifies that the method
 is case-sensitive.
 @p dataEncoding allows for the transmission of data as either URL-encoded form data,
 query string or JSON by passing the value TDOAuthContentTypeUrlEncodedForm,
 TDOAuthContentTypeUrlEncodedQuery or TDOAuthContentTypeJsonObject.
 This parameter is ignored for the requestMethod "GET".
 @p headerValues accepts a hash of key-value pairs (both must be strings) that specify
 HTTP header values to be included in the resulting URL Request. For example, the argument
 value @{@"Accept": @"application/json"} will include the header to indicate the server
 should respond with JSON. Other values are acceptable, depending on the server, but be
 careful. Values you supply will override the defaults which are set for User-Agent
 (set to "app-bundle-name/version" your app resources), Accept-Encoding (set to "gzip")
 and the calculated Authentication header. Attempting to specify the latter will be fatal.
 You should also avoid passing in values for the Content-Type and Content-Length header fields.
 @p signatureMethod accepts an enum and should normally be set to TDOAuthSignatureMethodHmacSha1.
 You have the option of using HMAC-SHA256 by setting this parameter to
 TDOAuthSignatureMethodHmacSha256; this is not included in the RFC for OAuth 1.0a, so most servers
 will not support it.
*/

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
                    signatureMethod:(OAuthSignatureMethod)signatureMethod;

/**
 OAuth requires the UTC timestamp we send to be accurate. The user's device
 may not be, and often isn't. To work around this you should set this to the
 UTC timestamp that you get back in HTTP headers from OAuth servers.
 */
+(int)utcTimeOffset;
+(void)setUtcTimeOffset:(int)offset;
@end

