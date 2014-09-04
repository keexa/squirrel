//
//  KXAppDelegate.m
//  CardCode
//
//  Created by Marco Bonifazi on 02/09/2014.
//  Copyright (c) 2014 Keexa. All rights reserved.
//

#import "KXAppDelegate.h"
#import "KXScanController.h"
#import <CoreData/CoreData.h>

@implementation KXAppDelegate


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (void) deleteItemsInArray: (NSArray *) arrayItems
                withContext:(NSManagedObjectContext *)managedObjectContext {
    
    for (NSManagedObject *entry in arrayItems) {
        [managedObjectContext deleteObject:entry];
    }
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    static NSPersistentStoreCoordinator *coordinator = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        
        // get the model
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        // get the coordinator
        coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        // add store
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *applicationSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
        [fileManager createDirectoryAtURL:applicationSupportURL withIntermediateDirectories:NO attributes:nil error:nil];
        NSString *dbName = NSBundle.mainBundle.infoDictionary [@"CFBundleDisplayName"];
        NSURL *databaseURL = [applicationSupportURL URLByAppendingPathComponent:[dbName stringByAppendingString: @".sqlite"]];

        NSError *error = nil;
        
        NSPersistentStore *store = [coordinator
                                    addPersistentStoreWithType:NSSQLiteStoreType
                                    configuration:nil
                                    URL:databaseURL
                                    options:nil
                                    error:&error];
        NSAssert(store, @"Unable to add persistent store\n%@", error);
        NSLog(@"databaseURL %@", databaseURL);
        
    });
    return coordinator;
}

+ (NSManagedObjectContext *)managedObjectContext {
    static NSManagedObjectContext *context = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [context setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    });
    return context;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    return YES;
}



- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"InAppSettings" ofType:@"bundle"];
    
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key && [[prefSpecification allKeys] containsObject:@"DefaultValue"]) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}



+ (BOOL) fetchItem:(NSString*) entityName
         WithAttribute:(NSString*) attribute
            AndContext:(NSManagedObjectContext *)managedObjectContext
               equalTo:(NSString*) item
{
    NSLog(@"%s - START - id: %@", __PRETTY_FUNCTION__, item);
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];

    [request setPredicate:[NSPredicate  predicateWithFormat:@"%K = %@", attribute, item]];
    [request setFetchLimit:1];

    NSLog(@"%s - START - descr: %@", __PRETTY_FUNCTION__, [request.predicate description]);
    
    ;
    NSError *error = nil;
    NSLog(@"%s - STOP", __PRETTY_FUNCTION__);
    
    NSUInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    if (count == NSNotFound ||
        count == 0) {
        return FALSE;
    } else {
        return TRUE;
    }
}

+ (BOOL) saveWithContext:(NSManagedObjectContext *)managedObjectContext {
    NSError __autoreleasing *error;
    BOOL success = [managedObjectContext save:&error];
    
    if (!success) {
        NSLog(@"Error saving context: %@", [error description]);
    } else {
        NSLog(@"Success");
    }
    return success;
}



@end
