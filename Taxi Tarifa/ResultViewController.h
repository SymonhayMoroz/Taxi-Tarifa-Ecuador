//
//  ResultViewController.h
//  Taxi Tarifa
//
//  Created by Symonhay M on 2/3/14.
//  Copyright (c) 10/10/2015 Symonhay M Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *fromAddressLabel;
@property (strong, nonatomic) IBOutlet UILabel *toAddressLabel;

@property (strong, nonatomic) IBOutlet UIButton *dayFareButton;
@property (strong, nonatomic) IBOutlet UIButton *nightFareButton;

@property (strong, nonatomic) IBOutlet UILabel *fareLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

- (IBAction)dayFareAction:(id)sender;
- (IBAction)nightFareAction:(id)sender;
- (IBAction)newFareAction:(id)sender;
- (IBAction)shareAction:(id)sender;


@end
