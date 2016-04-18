//
//  ToViewController.h
//  Taxi Tarifa
//
//  Created by Symonhay M on 1/31/14.
//  Copyright (c) 10/10/2015 Symonhay M Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface ToViewController : UIViewController <GMSMapViewDelegate>

@property (strong, nonatomic) IBOutlet GMSMapView *mapView;

@property (strong, nonatomic) IBOutlet UILabel *toAddressLabel;
@property (strong, nonatomic) IBOutlet UIButton *removePinButton;

@property (strong, nonatomic) GMSMarker *pinFrom;
@property (strong, nonatomic) GMSMarker *pinTo;
@property (strong, nonatomic) GMSMutablePath *path;

@property NSMutableArray *waypoints_;
@property NSMutableArray *waypointStrings_;

- (IBAction)removePinAction:(id)sender;

@end
