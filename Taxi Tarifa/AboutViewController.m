//
//  AboutViewController.m
//  Taxi Tarifa
//
//  Created by Symonhay M on 1/30/14.
//  Copyright (c) 10/10/2015 Symonhay M Interactive. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headerIcon"]];
    [self.containerView setContentSize:CGSizeMake(320, 504)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)antAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ant.gob.ec/tarifas/taxis.html"]];
}

- (IBAction)profkillsAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/profkills"]];
}

- (IBAction)josezam89Action:(id)sender {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/josezam89"]];
}

@end
