//
//  KXAppDelegate.h
//  CardCode
//
//  Created by Marco Bonifazi on 02/09/2014.
//  Copyright (c) 2014 Keexa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KXAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
+ (NSManagedObjectContext *)managedObjectContext ;
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
+ (BOOL) fetchItem:(NSString*) entityName
         WithAttribute:(NSString*) attribute
            AndContext:(NSManagedObjectContext *)managedObjectContext
               equalTo:(NSString*) item;
+ (BOOL) saveWithContext:(NSManagedObjectContext *)managedObjectContext;
+ (void) deleteItemsInArray: (NSArray *) arrayItems
                withContext:(NSManagedObjectContext *)managedObjectContext;
@end
