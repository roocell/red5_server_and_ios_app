//
//  AppDelegate.m
//  teleport
//
//  Created by michael russell on 2016-11-10.
//  Copyright © 2016 ThumbGenius Software. All rights reserved.
//

#import "AppDelegate.h"
#import "SSKeychain.h"
#import "teleport-Swift.h"  // include project-Swift.h to get switch function call

@interface AppDelegate ()

@end

@implementation AppDelegate

-(void) getServer
{
    // call swift function that has a completion handler from Obj-c
    [[ServerComms  new] getServer:^(NSDictionary* json) {
        _stream_server_ip=[json objectForKey:@"stream_server_ip"];
        _stream_server_port=[json objectForKey:@"stream_server_port"];
        
        TGLog(@"stream server: %@ %@", _stream_server_ip, _stream_server_port);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update the UI on the main thread.
            
        });
    }];
    
}


// using UUID to create a unique identifier for the device which I can use in the stream name when publishing
// in the future this could probably be a username or facebook hashed userid thing
- (NSString *)createNewUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return CFBridgingRelease(string);
}

-(void) getUuid
{
    // get UUID from persistant store or creates a new one and stores it.

    // getting the unique key (if present ) from keychain , assuming "your app identifier" as a key
    _uuid = [SSKeychain passwordForService:@"com.thumbgenius.teleport" account:@"uuid"];
    if (_uuid == nil) { // if this is the first time app lunching , create key for device
        _uuid  = [self createNewUUID];
        // save newly created key to Keychain
        [SSKeychain setPassword:_uuid forService:@"com.thumbgenius.teleport" account:@"uuid"];
        // this is the one time process
    }
}

-(void) registerUser
{
    // call swift function that has a completion handler from Obj-c
    [[ServerComms  new] registerUser:_apns_token completion:^(NSDictionary* json) {
        TGLog(@"%@", [json objectForKey:@"reason"]);
    }];
    
}

-(bool) checkUUID
{
    if (_uuid) return true;
    else {
        // should probably try registering again in case there was no internet connection when we tried last time
        // registerUser could take time since it's accessing the internet - we need to return false here and let the user try again.
        [self registerUser];
        return false;
    }
}

-(void) showInAppAlert:(NSDictionary*) userInfo
{
    TGLog(@"%@", userInfo);
    
    // show in-app alert
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    //AlertViewController* avc = (AlertViewController*) [storyboard        instantiateViewControllerWithIdentifier:@"ALERT_VIEW_CONTROLLER"];
    
    //avc.apns_data=[NSDictionary dictionaryWithDictionary:userInfo];
    
    //[_fvc presentViewController:avc animated:YES completion:^{}];
    
    
}

-(void) startApns:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // get UUID first - a lot of other classes depend on this existing prior to doing things
    [self getUuid];
    
    // Let the device know we want to receive push notifications
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    
    // Override point for customization after application launch.
    // Checking if application was launched by tapping icon, or push notification
    if (!launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        //TGLog(@"processing icon tap or notification tap");
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"userInfo.plist"];
        
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        NSDictionary *userInfo = [NSDictionary dictionaryWithContentsOfFile:filePath];
        if (userInfo) {
            // Launched by tapping icon
            // ... your handling here
            [self showInAppAlert:userInfo];
        }
    } else {
        //TGLog(@"processing swiped notification");
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo) {
            [self showInAppAlert:userInfo];
        }
    }
    

}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    //TGLog(@"APNS token is: %@", deviceToken);
    //TGLog(@"APNS hextoken is: %@", hexToken);
    
    _apns_token=[NSString stringWithString:hexToken];
    [self registerUser];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

-(void) writeUserInfoToFile:(NSDictionary*) userInfo
{
    // When we get a push, just writing it to file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"userInfo.plist"];
    [userInfo writeToFile:filePath atomically:YES];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{
    if(application.applicationState == UIApplicationStateInactive) {
        
        NSLog(@"Inactive");
        
        [self writeUserInfoToFile:userInfo];
        //Show the view with the content of the push
        [self showInAppAlert:userInfo];
        
        completionHandler(UIBackgroundFetchResultNewData);
        
    } else if (application.applicationState == UIApplicationStateBackground) {
        
        NSLog(@"Background");
        [self writeUserInfoToFile:userInfo];
        
        //Refresh the local model
        [self showInAppAlert:userInfo];
        
        completionHandler(UIBackgroundFetchResultNewData);
        
    } else {
        
        NSLog(@"Active");
        
        [self showInAppAlert:userInfo];
        
        completionHandler(UIBackgroundFetchResultNewData);
        
    }
    
    
    
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self getServer];
    [self startApns:application didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"teleport"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
