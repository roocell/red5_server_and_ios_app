//
//  ViewController.m
//  teleport
//
//  Created by michael russell on 2016-11-10.
//  Copyright © 2016 ThumbGenius Software. All rights reserved.
//

#import "ViewController.h"
#import "PublishExample.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showExample : (UIViewController*)viewController{
    
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"connection" ofType:@"plist"]];
    
    if([[dict objectForKey:@"domain"] isEqualToString:@"0.0.0.0"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Server!" message:@"Set the domain in your connection.plist!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
        
    }
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
    viewController.view = view;
    
    [self.navigationController pushViewController:viewController animated:YES];
    //[self presentViewController:viewController animated:YES completion:nil];
    
}

- (IBAction)onPublish:(id)sender {
    APPDEL;

    // cannot publish until we've registered the user and created a UUID
    if ([appdel checkUUID]==false)
    {
        TGLog(@"Cannot publush yet - no UUID");
        return;
    }
    [self showExample:[PublishExample new]];
}

@end
