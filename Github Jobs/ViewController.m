//
//  ViewController.m
//  Github Jobs
//
//  Created by Bohdan Kachur on 6/14/15.
//  Copyright (c) 2015 Modulus. All rights reserved.
//

#import "ViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
@interface ViewController ()

@property(nonatomic, strong) NSArray *jobs;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    NSString *endpoint = [[NSBundle bundleForClass:[self class]] infoDictionary][@"GithubJobsEndpoint"];
    
    NSURL *url = [NSURL URLWithString: endpoint                 ];
    NSURLSessionDataTask *jobTask = [[NSURLSession sharedSession] dataTaskWithURL:
                                     url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (error) {
                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"An error occured"
                                                                                                 message: error.localizedDescription
                                                                                                delegate: nil
                                                                                       cancelButtonTitle: @"Dismiss"
                                                                                       otherButtonTitles: nil];
                                                 [alert show];
                                                 return;
                                             }
                                             NSError *jsonError = nil;
                                             self.jobs = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &jsonError];
                                             
                                             [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%lu jobs fetched", (unsigned long)self.jobs.count]];
                                             
                                             [self.tableView reloadData];
                                         });
                                     }];
    [SVProgressHUD showWithStatus:@"Fetching jobs..."];
    [jobTask resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.jobs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.jobs[indexPath.row][@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *url = [NSURL URLWithString:self.jobs[indexPath.row][@"url"]];
    [[UIApplication sharedApplication] openURL:url];
}

@end
