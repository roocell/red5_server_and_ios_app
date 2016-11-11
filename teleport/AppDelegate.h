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

- (void)saveContext;


@end

