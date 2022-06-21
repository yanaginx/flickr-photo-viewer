//
//  UserAgent.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 21/06/2022.
//

#import <Foundation/Foundation.h>
#import "UserAgent.h"

NSString *UserAgent(void) {
    static NSString *ua;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id info = [NSBundle mainBundle].infoDictionary;
        id name = info[@"CFBundleDisplayName"] ?: info[(__bridge NSString *)kCFBundleIdentifierKey];
        id vers = (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) ?: info[(__bridge NSString *)kCFBundleVersionKey];
      #ifdef UIKIT_EXTERN
        float scale = ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [UIScreen mainScreen].scale : 1.0f);
        ua = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", name, vers, [UIDevice currentDevice].model, [UIDevice currentDevice].systemVersion, scale];
      #else
        ua = [NSString stringWithFormat:@"%@/%@", name, vers];
      #endif
    });
    return ua;
}
