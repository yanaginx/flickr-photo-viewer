//
//  Album+CoreDataProperties.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 18/07/2022.
//
//

#import "Album+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Album (CoreDataProperties)

+ (NSFetchRequest<Album *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSString *albumID;
@property (nullable, nonatomic, copy) NSString *albumImageURL;
@property (nullable, nonatomic, copy) NSString *albumName;
@property (nullable, nonatomic, copy) NSDate *creatationDate;
@property (nonatomic) int16_t numbersOfPhoto;
@property (nullable, nonatomic, retain) NSSet<AlbumPhoto *> *albumPhoto;

@end

@interface Album (CoreDataGeneratedAccessors)

- (void)addAlbumPhotoObject:(AlbumPhoto *)value;
- (void)removeAlbumPhotoObject:(AlbumPhoto *)value;
- (void)addAlbumPhoto:(NSSet<AlbumPhoto *> *)values;
- (void)removeAlbumPhoto:(NSSet<AlbumPhoto *> *)values;

@end

NS_ASSUME_NONNULL_END
