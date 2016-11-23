//
//  AppDelegate.h
//  teleport
//
//  Created by michael russell on 2016-11-10.
//  Copyright © 2016 ThumbGenius Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

// global app variables
// (another way to do this is to create a singleton class) - but this is easy
@property (retain, nonatomic) NSString* stream_server_ip;
@property (retain, nonatomic) NSNumber* stream_server_port;
@property (strong, nonatomic) NSString *apns_token;
@property (strong, nonatomic) NSString *uuid;

- (void)saveContext;
-(bool) checkUUID;
-(void) getServer;

@end

