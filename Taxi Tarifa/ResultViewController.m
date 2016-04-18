//
//  ResultViewController.m
//  Taxi Tarifa
//
//  Created by Symonhay M on 2/3/14.
//  Copyright (c) 10/10/2015 Symonhay M Interactive. All rights reserved.
//

#import "ResultViewController.h"

@interface ResultViewController ()

@end

@implementation ResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headerIcon"]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [_fromAddressLabel setText:[defaults objectForKey:@"fromAddress"]];
    [_toAddressLabel setText:[defaults objectForKey:@"toAddress"]];
    
    [_distanceLabel setText:[NSString stringWithFormat:@"Distancia Promedio: %@", [defaults objectForKey:@"distance"]]];
    [_timeLabel setText:[NSString stringWithFormat:@"Tiempo Estimado: %@", [defaults objectForKey:@"duration"]]];
    
    [_fareLabel setText:[self calculateFareWithDistance:[defaults objectForKey:@"distance"] time:[defaults objectForKey:@"duration"] dayFare:YES]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)calculateFareWithDistance:(NSString *)distance time:(NSString *)time dayFare:(BOOL)dayFare {
    float start = dayFare ? 0.35 : 0.40;
    float kmValue = dayFare ? 0.26 : 0.30;
    float minValue = dayFare ? 1.00 : 1.10;
    
    float cleanTime = [self cleanApiValues:time];
    float cleanDistance = [self cleanApiValues:distance];
    
    float timeFare = cleanTime * minValue;
    float distancefare = cleanDistance * kmValue;
    
    float preFare = start + ((timeFare + distancefare) / 3.0);
    float fare = 0.00;
    
    if (dayFare) {
        fare = preFare < 1.00 ? 1.00 : preFare;
    } else {
        fare = preFare < 1.10 ? 1.10 : preFare;
    }
    
    return [NSString stringWithFormat:@"$%.02f*", fare];
}

- (float)cleanApiValues:(NSString *)apiValue {
    return [[apiValue componentsSeparatedByString:@" "][0] floatValue];
}

- (IBAction)dayFareAction:(id)sender {
    [_dayFareButton setImage:[UIImage imageNamed:@"diurnaButtonOn"] forState:UIControlStateNormal];
    [_nightFareButton setImage:[UIImage imageNamed:@"nocturnaButtonOff"] forState:UIControlStateNormal];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [_fareLabel setText:[self calculateFareWithDistance:[defaults objectForKey:@"distance"] time:[defaults objectForKey:@"duration"] dayFare:YES]];
}

- (IBAction)nightFareAction:(id)sender {
    [_dayFareButton setImage:[UIImage imageNamed:@"diurnaButtonOff"] forState:UIControlStateNormal];
    [_nightFareButton setImage:[UIImage imageNamed:@"nocturnaButtonOn"] forState:UIControlStateNormal];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [_fareLabel setText:[self calculateFareWithDistance:[defaults objectForKey:@"distance"] time:[defaults objectForKey:@"duration"] dayFare:NO]];
}

- (IBAction)newFareAction:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [defaults dictionaryRepresentation];
    for (id key in dict) {
        if ([key isEqualToString:@"fromLat"] || [key isEqualToString:@"fromLon"]) {
            continue;
        }
        
        [defaults removeObjectForKey:key];
    }
    [defaults setObject:@"NO" forKey:@"newUser"];
    [defaults synchronize];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)shareAction:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *textToShare = [NSString stringWithFormat:@"Mi taxi desde %@ hasta %@ por %@. #TaxiTarifa", [defaults objectForKey:@"fromAddress"], [defaults objectForKey:@"toAddress"], [_fareLabel.text substringToIndex:_fareLabel.text.length - 1]];
    NSURL *urlToShare = [NSURL URLWithString:@"https://itunes.apple.com/ec/app/taxi-tarifa-ecuador/id814038242?ls=1&mt=8"];
    NSArray *activityItems = @[textToShare, urlToShare];
    
    UIActivityViewController *shareViewController = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:Nil];
    
    shareViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypePostToWeibo, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop];
    
    [self presentViewController:shareViewController animated:YES completion:NULL];
}

@end
