//
//  MenuTableViewController.m
//  teleport
//
//  Created by michael russell on 2016-11-14.
//  Copyright © 2016 ThumbGenius Software. All rights reserved.
//

#import "MenuTableViewController.h"
#import "SubscribeExample.h"
#import "AppDelegate.h"
#import "ALToastView.h"

@interface MenuTableViewController ()

@end

@implementation MenuTableViewController


// TODO: move to ServerComms
// can retrieve the streams or the users
-(void) getItems:(NSString*)url
{
    // get streams from server
    // https://www.raywenderlich.com/67081/cookbook-using-nsurlsession
    // more modern way than dataWithContentsOfURL

    TGLog(@"%@", url);
    NSURL *nsurl = [NSURL URLWithString:url];
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
          dataTaskWithURL:nsurl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
              if (error) {
                  TGLog(@"FAILED %@", error);
                  return;
              }
              
              NSError* jsonerror;
              NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:&jsonerror];
              
              if (jsonerror != nil) {
                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                  TGLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                  TGLog(@"%@", jsonerror);
                  return;
              }
              
              if (![[json objectForKey:@"status"] isEqualToString:@"success"])
              {
                  TGLog(@"ERR: failed for %@ reason %@", _mainMenuRow, [json objectForKey:@"status"]);
                  return;
              }

              
              _items = [NSMutableArray arrayWithArray:[json objectForKey:@"data"]];
              
              TGLog(@"%@ items: %@", _mainMenuRow, _items);
              
              dispatch_sync(dispatch_get_main_queue(), ^{
                  // Update the UI on the main thread.
                  [self.tableView reloadData];
              });
              
          }];
    [downloadTask resume];

}

// TODO: move to ServerComms
-(void) contactUser:(NSString*)uuid withMessage:(NSString*) message
{
    APPDEL;
    NSString *url = [NSString stringWithFormat:@"http://roocell.homeip.net:11111/user.php?cmd=contact&uuid=%@&dest_uuid=%@&message=%@", appdel.uuid, uuid, message];
    TGLog(@"%@", url);
    NSString * encodedUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    //NSString* encodedUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *nsurl = [NSURL URLWithString:encodedUrl];
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
      dataTaskWithURL:nsurl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
          if (error) {
              TGLog(@"FAILED %@", error);
              return;
          }
          
          NSError* jsonerror;
          NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingAllowFragments
                                                                 error:&jsonerror];
          
          if (jsonerror != nil) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
              TGLog(@"response status code: %ld", (long)[httpResponse statusCode]);
              TGLog(@"%@", jsonerror);
              return;
          }
          
          if (![[json objectForKey:@"status"] isEqualToString:@"success"])
          {
              TGLog(@"ERR: failed for %@ reason %@", _mainMenuRow, [json objectForKey:@"status"]);
              return;
          }
          
          TGLog(@"contacted %@:%@", uuid, message);
          
          [ALToastView toastInView:[[[UIApplication sharedApplication] keyWindow] rootViewController].view withText:[NSString stringWithFormat:@"contacted %@:%@", uuid, message]];
          
          dispatch_sync(dispatch_get_main_queue(), ^{
              // Update the UI on the main thread.
              [self.tableView reloadData];
          });
          
      }];
    [downloadTask resume];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    if ([_mainMenuRow isEqualToString:@"Streams"])
    {
        NSString *url = @"http://roocell.homeip.net:11111/red5list.php";
        [self getItems:url];
    } else if ([_mainMenuRow isEqualToString:@"Users"]) {
        APPDEL;
        NSString *url = [NSString stringWithFormat:@"http://roocell.homeip.net:11111/user.php?cmd=getuuids&uuid=%@", appdel.uuid];
        [self getItems:url];
    }

}

-(void)viewDidAppear:(BOOL)animated
{
    // because the orginal navigationController hid the navbar
    [self.navigationController setNavigationBarHidden:NO animated:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {  
    // we can have the same class do different formatting of this second level menu
    // also allows us to have different segues (in IB) to different view controllers for each meny selection
    NSString *CellIdentifier = @"STREAM_TABLE_CELL";
    if ([_mainMenuRow isEqualToString:@"Users"])
    {
        CellIdentifier = @"USER_TABLE_CELL";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    // Configure the cell...
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text=[_items objectAtIndex:[indexPath row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //UILabel *label = (UILabel *)[cell viewWithTag:1];

    if ([_mainMenuRow isEqualToString:@"Users"])
    {
        NSString* uuid=[_items objectAtIndex:[indexPath row]];
        TGLog(@"Selected %@", uuid);
        [self contactUser:uuid withMessage:@"Please take a video"];
    } else {
        // a segue in IB takes care of this case.
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    TGMark;
    
    if ([[segue identifier] isEqualToString:@"SUBSCRIBE_SEGUE"])
    {
        SubscribeExample  *vc = [segue destinationViewController];
        NSIndexPath* indexPath=[self.tableView indexPathForSelectedRow];
        vc.stream=[_items objectAtIndex:[indexPath row]];
    }
}





@end
