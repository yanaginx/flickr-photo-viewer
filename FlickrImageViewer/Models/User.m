//
//  User.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 02/07/2022.
//

#import "User.h"

@implementation User

- (instancetype)initWithNSID:(NSString *)nsid
                 accessToken:(NSString *)accessToken
                 secretToken:(NSString *)secretToken {
    if ((self = [super init])) {
        self.NSID = nsid;
        self.accessToken = accessToken;
        self.secretToken = secretToken;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.NSID forKey:@"NSID"];
    [encoder encodeObject:self.accessToken forKey:@"accessToken"];
    [encoder encodeObject:self.secretToken forKey:@"secretToken"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.NSID = [decoder decodeObjectForKey:@"NSID"];
        self.accessToken = [decoder decodeObjectForKey:@"accessToken"];
        self.secretToken = [decoder decodeObjectForKey:@"secretToken"];
    }
    return self;
}

@end
