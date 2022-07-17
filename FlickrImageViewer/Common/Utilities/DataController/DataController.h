//
//  DataController.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 17/07/2022.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataController : NSObject

@property (nonatomic, strong) NSPersistentContainer *persistentContainer;
@property (nonatomic, strong) NSManagedObjectContext *viewContext;
@property (nonatomic, strong) NSManagedObjectContext *backgroundContext;

- (instancetype)initWithModelName:(NSString *)modelName;
- (void)configureContexts;
- (void)loadWithCompletionHandler:(void (^)(void))block;
- (void)saveViewContext;
- (void)saveBackgroundContext;

@end

NS_ASSUME_NONNULL_END
