//
//  NSString+Additions.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 20/06/2022.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

- (NSString *) URLEncodedString {
    NSMutableString * output = [NSMutableString string];
    const char * source = [self UTF8String];
    unsigned long sourceLen = strlen(source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = (const unsigned char)source[i];
        if (false && thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end
