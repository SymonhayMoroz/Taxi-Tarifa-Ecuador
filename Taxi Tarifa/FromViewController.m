//
//  FromViewController.m
//  Taxi Tarifa
//
//  Created by Symonhay M on 1/30/14.
//  Copyright (c) 10/10/2015 Symonhay M Interactive. All rights reserved.
//

#import "FromViewController.h"
#import "AFNetworking.h"

@interface FromViewController ()

@end

@implementation FromViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView removeObserver:self forKeyPath:@"myLocation"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headerIcon"]];
    [_fromAddressLabel setAdjustsFontSizeToFitWidth:YES];
    [self setupMapView];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"newUser"]) {
        [_overlayView setHidden:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"myLocation"] && [object isKindOfClass:[GMSMapView class]]) {
        NSLog(@"User Location is: %f,%f", _mapView.myLocation.coordinate.latitude, _mapView.myLocation.coordinate.longitude);
        
        if (_firstTimeLaunch) {
            CLLocationDegrees lat = _mapView.myLocation.coordinate.latitude;
            CLLocationDegrees lon = _mapView.myLocation.coordinate.longitude;
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat longitude:lon zoom:15];
            [_mapView setCamera:camera];
            _firstTimeLaunch = NO;
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithFloat:_mapView.myLocation.coordinate.latitude] forKey:@"fromLat"];
        [defaults setObject:[NSNumber numberWithFloat:_mapView.myLocation.coordinate.longitude] forKey:@"fromLon"];
        [defaults synchronize];
        
        [self reverseGeocodeLatitude:_mapView.myLocation.coordinate.latitude andLongitude:_mapView.myLocation.coordinate.longitude inLabel:_fromAddressLabel];
    }
}

- (void)setupMapView {
    _firstTimeLaunch = YES;
    
    _mapView.delegate = self;
    _mapView.myLocationEnabled = YES;
    _mapView.settings.myLocationButton = YES;
    
    CLLocationDegrees lat = -1.831239;
    CLLocationDegrees lon = -78.18340599999999;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat longitude:lon zoom:6];
    [_mapView setCamera:camera];
    
    // [self drawMapBounds];
}

- (void)drawMapBounds {
    _path = [GMSMutablePath path];
    [_path addCoordinate:CLLocationCoordinate2DMake(-5.014351, -81.084981)];
    [_path addCoordinate:CLLocationCoordinate2DMake(1.428418, -81.084981)];
    [_path addCoordinate:CLLocationCoordinate2DMake(1.428418, -75.188794)];
    [_path addCoordinate:CLLocationCoordinate2DMake(-5.014351, -75.188794)];
    [_path addCoordinate:CLLocationCoordinate2DMake(-5.014351, -81.084981)];
    
    GMSPolyline *ecuadorLimitsLine = [GMSPolyline polylineWithPath:_path];
    ecuadorLimitsLine.strokeColor = [UIColor redColor];
    ecuadorLimitsLine.strokeWidth = 2;
    ecuadorLimitsLine.map = _mapView;
}

- (void)clearMapAnnotations {
    [_mapView clear];
    _pinFrom = nil;
    [_removePinButton setHidden:YES];
    [_fromAddressLabel setText:@"obteniendo dirección..."];
    _mapView.myLocationEnabled = YES;
}

- (void)reverseGeocodeLatitude:(float)latitude andLongitude:(float)longitude inLabel:(UILabel *)label {
    NSString *gcQueryPath = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=false", latitude, longitude];
    
    NSLog(@"Querying %@", gcQueryPath);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:gcQueryPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject valueForKeyPath:@"results"] count] > 0) {
            NSLog(@"Address from API: %@", [[[responseObject valueForKeyPath:@"results"] objectAtIndex:0] valueForKeyPath:@"formatted_address"]);
            
            NSString *displayAddress = [[[[[responseObject valueForKeyPath:@"results"] objectAtIndex:0] valueForKeyPath:@"formatted_address"] componentsSeparatedByString:@","] objectAtIndex:0];
            
            [label setText:displayAddress];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:displayAddress forKey:@"fromAddress"];
            [defaults synchronize];
        } else {
            [label setText:[NSString stringWithFormat:@"%f,%f", latitude, longitude]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [label setText:[NSString stringWithFormat:@"%f,%f", latitude, longitude]];
    }];
}

- (IBAction)helpAction:(id)sender {
    BOOL toggle = ![_overlayView isHidden];
    [_overlayView setHidden:toggle];
}

- (IBAction)removePinAction:(id)sender {
    [self clearMapAnnotations];
}

- (IBAction)dismissOverlayAction:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"NO" forKey:@"newUser"];
    [defaults synchronize];
    
    [_overlayView setHidden:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"toDestinationSegue"]) {
        if (_pinFrom.position.latitude != 0.0 && _pinFrom.position.longitude != 0.0) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSNumber numberWithFloat:_pinFrom.position.latitude] forKey:@"fromLat"];
            [defaults setObject:[NSNumber numberWithFloat:_pinFrom.position.longitude] forKey:@"fromLon"];
            [defaults synchronize];
        }
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if([identifier isEqualToString:@"toDestinationSegue"]) {
        if (_mapView.myLocation.coordinate.latitude == 0.0 && _mapView.myLocation.coordinate.longitude == 00 && _pinFrom.position.latitude == 0.0 && _pinFrom.position.longitude == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Taxi Tarifa" message:@"Por favor, elige un punto de partida o espera a que la aplicación encuentre la dirección de tu ubicación." delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil];
            [alert show];
            
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Google Map View delegate methods

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    BOOL isInsideEcuador = (coordinate.latitude < 1.428418 &&  coordinate.latitude > -5.014351) && (coordinate.longitude < -75.188794 && coordinate.longitude > -81.084981);
    
    if (isInsideEcuador) {
        [self clearMapAnnotations];
        
        _pinFrom = [GMSMarker markerWithPosition:coordinate];
        _pinFrom.icon = [GMSMarker markerImageWithColor:[UIColor colorWithRed:31.0/255.0 green:174.0/255.0 blue:227.0/255.0 alpha:1.0]];
        _pinFrom.map = _mapView;
        
        [_removePinButton setHidden:NO];
        _mapView.myLocationEnabled = NO;
        
        [self reverseGeocodeLatitude:coordinate.latitude andLongitude:coordinate.longitude inLabel:_fromAddressLabel];
        
        NSLog(@"Pin set at: %f,%f", coordinate.latitude, coordinate.longitude);
    } else {
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Taxi Tarifa" message:NSLocalizedString(@"PIN_NOT_IN_AREA", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ACCEPT", nil) otherButtonTitles:nil, nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Taxi Tarifa" message:@"Solo puedes elegir ubicaciones dentro de Ecuador." delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil];
        [alert show];
    }
}

@end
