//
//  DataController.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 17/07/2022.
//

#import "DataController.h"

@implementation DataController

- (instancetype)initWithModelName:(NSString *)modelName {
    self = [super init];
    if (self) {
        self.persistentContainer = [[NSPersistentContainer alloc] initWithName:modelName];
    }
    return self;
}

- (NSManagedObjectContext *)viewContext {
    return self.persistentContainer.viewContext;
}

- (void)configureContexts {
    self.backgroundContext = [self.persistentContainer newBackgroundContext];
    
    [self.viewContext setAutomaticallyMergesChangesFromParent:YES];
    [self.backgroundContext setAutomaticallyMergesChangesFromParent:YES];
    
    [self.viewContext setMergePolicy:[NSMergePolicy mergeByPropertyStoreTrumpMergePolicy]];
    [self.backgroundContext setMergePolicy:[NSMergePolicy mergeByPropertyObjectTrumpMergePolicy]];
}

- (void)loadWithCompletionHandler:(void (^)(void))block {
    [self.persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
        if (error != nil) {
            NSLog(@"[ERROR] %@ : %@", error, error.localizedDescription);
            abort();
        }
        [self configureContexts];
        block();
    }];
}

- (void)saveViewContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

- (void)saveBackgroundContext {
    NSManagedObjectContext *context = self.backgroundContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
