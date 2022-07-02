//
//  NSUserDefaults+Additions.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 02/07/2022.
//

#import "NSUserDefaults+Additions.h"
#import "../../Models/User.h"

@implementation NSUserDefaults (Additions)

- (void)saveUserObject:(id<NSCoding>)object
                   key:(NSString *)key {
    NSError *localError = nil;
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object
                                                  requiringSecureCoding:YES
                                                                  error:&localError];
    if (localError) {
        NSLog(@"[DEBUG] %s : error occured: %@",
              __func__,
              localError);
        return;
    }
    [self setObject:encodedObject forKey:key];
    [self synchronize];
}

- (id<NSCoding>)loadUserObjectWithKey:(NSString *)key {
    NSError *localError = nil;
    NSData *encodedObject = [self objectForKey:key];
    NSSet *setOfClasses = [NSSet setWithObjects:[User class], [NSString class], nil];
    id<NSCoding> object = [NSKeyedUnarchiver unarchivedObjectOfClasses:setOfClasses
                                                              fromData:encodedObject
                                                                 error:&localError];
    if (localError) {
        NSLog(@"[DEBUG] %s : error occured: %@",
              __func__,
              localError);
        return nil;
    }

    return object;
}

@end
