//
//  RTCObjBridgeView.m
//  teleport
//
//  Created by michael russell on 2016-12-04.
//  Copyright © 2016 Facebook. All rights reserved.
//
// this is a simple objc object whos only job is to call a objc view controller
// reaact JS code can call this to push an objc view controller
//
//http://stackoverflow.com/questions/36562274/how-can-i-present-a-native-uiviewcontroller-in-react-native-cant-use-just-a-u


#import "RTCObjBridgeView.h"
#import "AppDelegate.h"
#import "util.h"
#import "PublishExample.h"

@implementation RTCObjBridgeView

// http://moduscreate.com/leverage-existing-ios-views-react-native-app/
// https://www.raywenderlich.com/136047/react-native-existing-app

RCT_EXPORT_MODULE();

// define prop types in JS for these
// http://browniefed.com/blog/react-native-how-to-bridge-an-objective-c-view-component/
//RCT_EXPORT_VIEW_PROPERTY(src, NSString);
//RCT_EXPORT_VIEW_PROPERTY(contentMode, NSNumber);

- (void)backButtonPressed:(id)sender {
  APPDEL;
  [appdel.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

RCT_EXPORT_METHOD(showPublish) {
  TGMark;
  dispatch_async(dispatch_get_main_queue(), ^{
    PublishExample *p = [[PublishExample alloc] init];
    p.stream_server_ip=@"184.146.38.69";
    p.stream_server_port=[NSNumber numberWithInt:8554];
    p.stream_identifier=@"mystream"; // TODO: set to UUID
    APPDEL;

    
    NSArray *vcs = appdel.window.rootViewController.childViewControllers;
    
    for (int i = 0 ; i <vcs.count; i++){
      TGLog(@"%d %@", i, ((UIViewController*)[vcs objectAtIndex:i]).class);
      //if ([[vcs objectAtIndex:i] isKindOfClass:UINavigationController]) {
      //}
    }
    
    //UIViewController *mainNav = appdel.window.rootViewController.childViewControllers[0];
    
    //UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:p];
    //UIBarButtonItem *_backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed:)];
    
    //navVC.navigationItem.backBarButtonItem = _backButton;

    [appdel.window.rootViewController presentViewController:p animated:YES completion:nil];
  });
}



@end
