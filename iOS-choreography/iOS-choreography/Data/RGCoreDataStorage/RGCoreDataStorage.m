//
//  RGCoreDataStorage.m
//  jumpstart
//
//  Created by Ryan Goce on 10/6/15.
//  Copyright (c) 2015 Ryan Goce. All rights reserved.
//
#import "RGCoreDataStorage.h"


#import <objc/runtime.h>
#import <libkern/OSAtomic.h>

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


@implementation RGCoreDataStorage

static NSMutableSet *databaseFileNames;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        databaseFileNames = [[NSMutableSet alloc] init];
    });
}

+ (BOOL)registerDatabaseFileName:(NSString *)dbFileName
{
    BOOL result = NO;
    
    @synchronized(databaseFileNames)
    {
        if (![databaseFileNames containsObject:dbFileName])
        {
            [databaseFileNames addObject:dbFileName];
            result = YES;
        }
    }
    
    return result;
}

+ (void)unregisterDatabaseFileName:(NSString *)dbFileName
{
    @synchronized(databaseFileNames)
    {
        [databaseFileNames removeObject:dbFileName];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Override Me
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)managedObjectModelName
{
    // Override me, if needed, to provide customized behavior.
    //
    // This method is queried to get the name of the ManagedObjectModel within the app bundle.
    // It should return the name of the appropriate file (*.xdatamodel / *.mom / *.momd) sans file extension.
    //
    // The default implementation returns the name of the subclass, stripping any suffix of "CoreDataStorage".
    // E.g., if your subclass was named "XMPPExtensionCoreDataStorage", then this method would return "XMPPExtension".
    //
    // Note that a file extension should NOT be included.
    
    NSString *className = NSStringFromClass([self class]);
    NSString *suffix = @"CoreDataStorage";
    
    if ([className hasSuffix:suffix] && ([className length] > [suffix length]))
    {
        return [className substringToIndex:([className length] - [suffix length])];
    }
    else
    {
        return className;
    }
}

- (NSString *)defaultDatabaseFileName
{
    // Override me, if needed, to provide customized behavior.
    //
    // This method is queried if the initWithDatabaseFileName method is invoked with a nil parameter.
    //
    // You are encouraged to use the sqlite file extension.
    
    return [NSString stringWithFormat:@"%@.sqlite", [self managedObjectModelName]];
}

- (void)willCreatePersistentStoreWithPath:(NSString *)storePath
{
    // Override me, if needed, to provide customized behavior.
    //
    // If you are using a database file with pure non-persistent data (e.g. for memory optimization purposes on iOS),
    // you may want to delete the database file if it already exists on disk.
    //
    // If this instance was created via initWithDatabaseFilename, then the storePath parameter will be non-nil.
    // If this instance was created via initWithInMemoryStore, then the storePath parameter will be nil.
}

- (BOOL)addPersistentStoreWithPath:(NSString *)storePath error:(NSError **)errorPtr
{
    // Override me, if needed, to completely customize the persistent store.
    //
    // Adds the persistent store path to the persistent store coordinator.
    // Returns true if the persistent store is created.
    //
    // If this instance was created via initWithDatabaseFilename, then the storePath parameter will be non-nil.
    // If this instance was created via initWithInMemoryStore, then the storePath parameter will be nil.
    
    NSPersistentStore *persistentStore;
    
    if (storePath)
    {
        // SQLite persistent store
        
        NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
        
        // Default support for automatic lightweight migrations
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                                 nil];
        
        persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                   configuration:nil
                                                                             URL:storeUrl
                                                                         options:options
                                                                           error:errorPtr];
    }
    else
    {
        // In-Memory persistent store
        
        persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                                   configuration:nil
                                                                             URL:nil
                                                                         options:nil
                                                                           error:errorPtr];
    }
    
    return persistentStore != nil;
}

- (void)didNotAddPersistentStoreWithPath:(NSString *)storePath error:(NSError *)error
{
    // Override me, if needed, to provide customized behavior.
    //
    // For example, if you are using the database for non-persistent data and the model changes,
    // you may want to delete the database file if it already exists on disk.
    //
    // E.g:
    //
    // [[NSFileManager defaultManager] removeItemAtPath:storePath error:NULL];
    // [self addPersistentStoreWithPath:storePath error:NULL];
    //
    // This method is invoked on the storageQueue.
    
    
}

- (void)didCreateManagedObjectContext
{
    // Override me to provide customized behavior.
    // For example, you may want to perform cleanup of any non-persistent data before you start using the database.
    //
    // This method is invoked on the storageQueue.
}

- (void)willSaveManagedObjectContext
{
    // Override me if you need to do anything special just before changes are saved to disk.
    //
    // This method is invoked on the storageQueue.
}

- (void)didSaveManagedObjectContext
{
    // Override me if you need to do anything special after changes have been saved to disk.
    //
    // This method is invoked on the storageQueue.
}

- (void)mainThreadManagedObjectContextDidMergeChanges
{
    // Override me if you want to do anything special when changes get propogated to the main thread.
    //
    // This method is invoked on the main thread.
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@synthesize databaseFileName;

- (void)commonInit
{
    saveThreshold = 500;
    
    storageQueue = dispatch_queue_create(class_getName([self class]), NULL);
    
    storageQueueTag = &storageQueueTag;
    dispatch_queue_set_specific(storageQueue, storageQueueTag, storageQueueTag, NULL);
}

- (id)init
{
    return [self initWithDatabaseFilename:nil];
}

- (id)initWithDatabaseFilename:(NSString *)aDatabaseFileName
{
    if ((self = [super init]))
    {
        if (aDatabaseFileName)
            databaseFileName = [aDatabaseFileName copy];
        else
            databaseFileName = [[self defaultDatabaseFileName] copy];
        
        if (![[self class] registerDatabaseFileName:databaseFileName])
        {
            return nil;
        }
        
        [self commonInit];
        NSAssert(storageQueue != NULL, @"Subclass forgot to invoke [super commonInit]");
    }
    return self;
}

- (id)initWithInMemoryStore
{
    if ((self = [super init]))
    {
        [self commonInit];
        NSAssert(storageQueue != NULL, @"Subclass forgot to invoke [super commonInit]");
    }
    return self;
}

- (BOOL)configureWithParent:(id)aParent queue:(dispatch_queue_t)queue
{
    // This is the standard configure method used by xmpp extensions to configure a storage class.
    //
    // Feel free to override this method if needed,
    // and just invoke super at some point to make sure everything is kosher at this level as well.
    
    NSParameterAssert(aParent != nil);
    NSParameterAssert(queue != NULL);
    
    if (queue == storageQueue)
    {
        // This class is designed to be run on a separate dispatch queue from its parent.
        // This allows us to optimize the database save operations by buffering them,
        // and executing them when demand on the storage instance is low.
        
        return NO;
    }
    
    return YES;
}

- (NSUInteger)saveThreshold
{
    if (dispatch_get_specific(storageQueueTag))
    {
        return saveThreshold;
    }
    else
    {
        __block NSUInteger result;
        
        dispatch_sync(storageQueue, ^{
            result = saveThreshold;
        });
        
        return result;
    }
}

- (void)setSaveThreshold:(NSUInteger)newSaveThreshold
{
    dispatch_block_t block = ^{
        saveThreshold = newSaveThreshold;
    };
    
    if (dispatch_get_specific(storageQueueTag))
        block();
    else
        dispatch_async(storageQueue, block);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data Setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)persistentStoreDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    
    // Attempt to find a name for this application
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (appName == nil) {
        appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    }
    
    if (appName == nil) {
        appName = @"xmppframework";
    }
    
    
    NSString *result = [basePath stringByAppendingPathComponent:appName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:result])
    {
        [fileManager createDirectoryAtPath:result withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return result;
}

- (NSManagedObjectModel *)managedObjectModel
{
    // This is a public method.
    // It may be invoked on any thread/queue.
    
    __block NSManagedObjectModel *result = nil;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        if (managedObjectModel)
        {
            result = managedObjectModel;
            return;
        }
        
        NSString *momName = [self managedObjectModelName];
        
        NSString *momPath = [[NSBundle mainBundle] pathForResource:momName ofType:@"mom"];
        if (momPath == nil)
        {
            // The model may be versioned or created with Xcode 4, try momd as an extension.
            momPath = [[NSBundle mainBundle] pathForResource:momName ofType:@"momd"];
        }
        
        if (momPath)
        {
            // If path is nil, then NSURL or NSManagedObjectModel will throw an exception
            
            NSURL *momUrl = [NSURL fileURLWithPath:momPath];
            
            managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momUrl];
        }
        else
        {
            
        }
        
        result = managedObjectModel;
    }};
    
    if (dispatch_get_specific(storageQueueTag))
        block();
    else
        dispatch_sync(storageQueue, block);
    
    return result;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    // This is a public method.
    // It may be invoked on any thread/queue.
    
    __block NSPersistentStoreCoordinator *result = nil;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        if (persistentStoreCoordinator)
        {
            result = persistentStoreCoordinator;
            return;
        }
        
        NSManagedObjectModel *mom = [self managedObjectModel];
        if (mom == nil)
        {
            return;
        }
        
        
        
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
        
        if (databaseFileName)
        {
            // SQLite persistent store
            
            NSString *docsPath = [self persistentStoreDirectory];
            NSString *storePath = [docsPath stringByAppendingPathComponent:databaseFileName];
            if (storePath)
            {
                // If storePath is nil, then NSURL will throw an exception
                
                [self willCreatePersistentStoreWithPath:storePath];
                
                NSError *error = nil;
                if (![self addPersistentStoreWithPath:storePath error:&error])
                {
                    [self didNotAddPersistentStoreWithPath:storePath error:error];
                }
            }
            else
            {
                
            }
        }
        else
        {
            // In-Memory persistent store
            
            [self willCreatePersistentStoreWithPath:nil];
            
            NSError *error = nil;
            if (![self addPersistentStoreWithPath:nil error:&error])
            {
                [self didNotAddPersistentStoreWithPath:nil error:error];
            }
        }
        
        result = persistentStoreCoordinator;
        
    }};
    
    if (dispatch_get_specific(storageQueueTag))
        block();
    else
        dispatch_sync(storageQueue, block);
    
    return result;
}

- (NSManagedObjectContext *)managedObjectContext
{
    // This is a private method.
    //
    // NSManagedObjectContext is NOT thread-safe.
    // Therefore it is VERY VERY BAD to use our private managedObjectContext outside our private storageQueue.
    //
    // You should NOT remove the assert statement below!
    // You should NOT give external classes access to the storageQueue! (Excluding subclasses obviously.)
    //
    // When you want a managedObjectContext of your own (again, excluding subclasses),
    // you can use the mainThreadManagedObjectContext (below),
    // or you should create your own using the public persistentStoreCoordinator.
    //
    // If you even comtemplate ignoring this warning,
    // then you need to go read the documentation for core data,
    // specifically the section entitled "Concurrency with Core Data".
    //
    NSAssert(dispatch_get_specific(storageQueueTag), @"Invoked on incorrect queue");
    //
    // Do NOT remove the assert statment above!
    // Read the comments above!
    //
    
    if (managedObjectContext)
    {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator)
    {
        if ([NSManagedObjectContext instancesRespondToSelector:@selector(initWithConcurrencyType:)])
            managedObjectContext =
            [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
        else
            managedObjectContext = [[NSManagedObjectContext alloc] init];
        
        managedObjectContext.persistentStoreCoordinator = coordinator;
        managedObjectContext.undoManager = nil;
        
        [self didCreateManagedObjectContext];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectContext *)mainThreadManagedObjectContext
{
    // NSManagedObjectContext is NOT thread-safe.
    // Therefore it is VERY VERY BAD to use this managedObjectContext outside the main thread.
    //
    // You should NOT remove the assert statement below!
    //
    // When you want a managedObjectContext of your own for non-main-thread use,
    // you should create your own using the public persistentStoreCoordinator.
    //
    // If you even comtemplate ignoring this warning,
    // then you need to go read the documentation for core data,
    // specifically the section entitled "Concurrency with Core Data".
    //
    NSAssert([NSThread isMainThread], @"Context reserved for main thread only");
    //
    // Do NOT remove the assert statment above!
    // Read the comments above!
    //
    
    if (mainThreadManagedObjectContext)
    {
        return mainThreadManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator)
    {
        
        if ([NSManagedObjectContext instancesRespondToSelector:@selector(initWithConcurrencyType:)])
            mainThreadManagedObjectContext =
            [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        else
            mainThreadManagedObjectContext = [[NSManagedObjectContext alloc] init];
        
        mainThreadManagedObjectContext.persistentStoreCoordinator = coordinator;
        mainThreadManagedObjectContext.undoManager = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(managedObjectContextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];
        
        // TODO: If we knew that our private managedObjectContext was going to be the only one writing to the database,
        // then a small optimization would be to use it as the object when registering above.
    }
    
    return mainThreadManagedObjectContext;
}

- (void)managedObjectContextDidSave:(NSNotification *)notification
{
    NSManagedObjectContext *sender = (NSManagedObjectContext *)[notification object];
    
    if ((sender != mainThreadManagedObjectContext) &&
        (sender.persistentStoreCoordinator == mainThreadManagedObjectContext.persistentStoreCoordinator))
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [mainThreadManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
            [self mainThreadManagedObjectContextDidMergeChanges];
        });
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Utilities
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSUInteger)numberOfUnsavedChanges
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    NSUInteger unsavedCount = 0;
    unsavedCount += [[moc updatedObjects] count];
    unsavedCount += [[moc insertedObjects] count];
    unsavedCount += [[moc deletedObjects] count];
    
    return unsavedCount;
}

- (void)save
{
    // I'm fairly confident that the implementation of [NSManagedObjectContext save:]
    // internally checks to see if it has anything to save before it actually does anthing.
    // So there's no need for us to do it here, especially since this method is usually
    // called from maybeSave below, which already does this check.
    
    [self willSaveManagedObjectContext];
    
    NSError *error = nil;
    if ([[self managedObjectContext] save:&error])
    {
        saveCount++;
        [self didSaveManagedObjectContext];
    }
    else
    {
        
        [[self managedObjectContext] rollback];
    }
}

- (void)maybeSave:(int32_t)currentPendingRequests
{
    NSAssert(dispatch_get_specific(storageQueueTag), @"Invoked on incorrect queue");
    
    
    if ([[self managedObjectContext] hasChanges])
    {
        if (currentPendingRequests == 0)
        {
            
            [self save];
        }
        else
        {
            NSUInteger unsavedCount = [self numberOfUnsavedChanges];
            if (unsavedCount >= saveThreshold)
            {
                
                [self save];
            }
        }
    }
}

- (void)maybeSave
{
    // Convenience method in the very rare case that a subclass would need to invoke maybeSave manually.
    
    [self maybeSave:OSAtomicAdd32(0, &pendingRequests)];
}

- (void)saveBlock:(dispatch_block_t)block
{
    // By design this method should not be invoked from the storageQueue.
    //
    // If you remove the assert statement below, you are destroying the sole purpose for this class,
    // which is to optimize the disk IO by buffering save operations.
    //
    NSAssert(!dispatch_get_specific(storageQueueTag), @"Invoked on incorrect queue");
    //
    // For a full discussion of this method, please see XMPPCoreDataStorageProtocol.h
    //
    // dispatch_Sync
    //          ^
    
    dispatch_sync(storageQueue, ^{ @autoreleasepool {
        
        block();
        
        [self save];
        
    }});
}

- (void)executeBlock:(dispatch_block_t)block
{
    // By design this method should not be invoked from the storageQueue.
    // 
    // If you remove the assert statement below, you are destroying the sole purpose for this class,
    // which is to optimize the disk IO by buffering save operations.
    // 
    NSAssert(!dispatch_get_specific(storageQueueTag), @"Invoked on incorrect queue");
    // 
    // For a full discussion of this method, please see XMPPCoreDataStorageProtocol.h
    //
    // dispatch_Sync
    //          ^
    
    OSAtomicIncrement32(&pendingRequests);
    dispatch_sync(storageQueue, ^{ @autoreleasepool {
        
        block();
        
        // Since this is a synchronous request, we want to return as quickly as possible.
        // So we delay the maybeSave operation til later.
        
        dispatch_async(storageQueue, ^{ @autoreleasepool {
            
            [self maybeSave:OSAtomicDecrement32(&pendingRequests)];
        }});
        
    }});
}

- (void)scheduleBlock:(dispatch_block_t)block
{
    // By design this method should not be invoked from the storageQueue.
    // 
    // If you remove the assert statement below, you are destroying the sole purpose for this class,
    // which is to optimize the disk IO by buffering save operations.
    // 
    NSAssert(!dispatch_get_specific(storageQueueTag), @"Invoked on incorrect queue");
    // 
    // For a full discussion of this method, please see XMPPCoreDataStorageProtocol.h
    // 
    // dispatch_Async
    //          ^
    
    OSAtomicIncrement32(&pendingRequests);
    dispatch_async(storageQueue, ^{ @autoreleasepool {
        
        block();
        [self maybeSave:OSAtomicDecrement32(&pendingRequests)];
    }});
}

- (void)waitBlock:(dispatch_block_t)block {
    
    if (dispatch_get_specific(storageQueueTag)) {
        block();
    }
    else {
        dispatch_sync(storageQueue, block);
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Memory Management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (databaseFileName)
    {
        [[self class] unregisterDatabaseFileName:databaseFileName];
    }
    
#if !OS_OBJECT_USE_OBJC
    if (storageQueue)
        dispatch_release(storageQueue);
#endif
}

@end
