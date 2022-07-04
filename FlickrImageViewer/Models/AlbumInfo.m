//
//  AlbumInfo.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 04/07/2022.
//

#import "AlbumInfo.h"

@implementation AlbumInfo

- (instancetype)initWithAlbumID:(NSString *)albumID
                       imageURL:(NSURL *)url
                      albumName:(NSString *)name
                    dateCreated:(NSDate *)date
                 numberOfPhotos:(NSInteger)number {
    self = [super init];
    if (self) {
        self.albumID = albumID;
        self.albumImageURL = url;
        self.albumName = name;
        self.dateCreated = date;
        self.numberOfPhotos = number;
    }
    return self;
}

- (instancetype)initWithAlbumImageURL:(NSURL *)url
                            albumName:(NSString *)name
                          dateCreated:(NSDate *)date
                       numberOfPhotos:(NSInteger)number {
    self = [super init];
    if (self) {
        self.albumImageURL = url;
        self.albumName = name;
        self.dateCreated = date;
        self.numberOfPhotos = number;
    }
    return self;
}

@end
