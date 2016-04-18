//
//  ToViewController.m
//  Taxi Tarifa
//
//  Created by Symonhay M on 1/31/14.
//  Copyright (c) 10/10/2015 Symonhay M Interactive. All rights reserved.
//

#import "ToViewController.h"
#import "AFNetworking.h"
#import "MDDirectionService.h"

@interface ToViewController ()

@end

@implementation ToViewController

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
    [_toAddressLabel setAdjustsFontSizeToFitWidth:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"From location %f,%f", [[defaults objectForKey:@"fromLat"] floatValue], [[defaults objectForKey:@"fromLon"] floatValue]);
    
    _waypoints_ = [NSMutableArray array];
    _waypointStrings_ = [NSMutableArray array];
    [self setupMapView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupMapView {
    _mapView.delegate = self;
    // _mapView.myLocationEnabled = YES;
    // _mapView.settings.myLocationButton = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    CLLocationDegrees lat = [[defaults objectForKey:@"fromLat"] floatValue];
    CLLocationDegrees lon = [[defaults objectForKey:@"fromLon"] floatValue];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat longitude:lon zoom:15];
    [_mapView setCamera:camera];
    
    [self restoreFromLocation];
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
    _pinTo = nil;
    [_removePinButton setHidden:YES];
    _waypoints_ = [NSMutableArray array];
    _waypointStrings_ = [NSMutableArray array];
    [self restoreFromLocation];
    [_toAddressLabel setText:@"selecciona tu destino..."];
}

- (void)restoreFromLocation {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CLLocationDegrees lat = [[defaults objectForKey:@"fromLat"] floatValue];
    CLLocationDegrees lon = [[defaults objectForKey:@"fromLon"] floatValue];
    
    _pinFrom = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(lat, lon)];
    _pinFrom.title = @"Punto de Partida";
    _pinFrom.icon = [GMSMarker markerImageWithColor:[UIColor colorWithRed:31.0/255.0 green:174.0/255.0 blue:227.0/255.0 alpha:1.0]];
    _pinFrom.map = _mapView;
    
    [_waypoints_ addObject:_pinFrom];
    NSString *positionString = [[NSString alloc] initWithFormat:@"%f,%f", _pinFrom.position.latitude, _pinFrom.position.longitude];
    [_waypointStrings_ addObject:positionString];
}

- (IBAction)removePinAction:(id)sender {
    [self clearMapAnnotations];
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
            [defaults setObject:displayAddress forKey:@"toAddress"];
            [defaults synchronize];
        } else {
            [label setText:[NSString stringWithFormat:@"%f,%f", latitude, longitude]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [label setText:[NSString stringWithFormat:@"%f,%f", latitude, longitude]];
    }];
}

- (void)addDirections:(NSDictionary *)json {
    
    NSDictionary *routes = [json objectForKey:@"routes"][0];
    
    NSString *distance = [[[routes objectForKey:@"legs"][0] objectForKey:@"distance"] objectForKey:@"text"];
    NSString *duration = [[[routes objectForKey:@"legs"][0] objectForKey:@"duration"] objectForKey:@"text"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:distance forKey:@"distance"];
    [defaults setObject:duration forKey:@"duration"];
    [defaults synchronize];
    
    NSDictionary *route = [routes objectForKey:@"overview_polyline"];
    NSString *overview_route = [route objectForKey:@"points"];
    
    GMSPath *path = [GMSPath pathFromEncodedPath:overview_route];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeWidth = 10;
    polyline.strokeColor = [UIColor greenColor];
    polyline.map = _mapView;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"selectCalculateSegue"]) {
        if (_pinTo.position.latitude != 0.0 && _pinTo.position.longitude != 0.0) {
            return YES;
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Taxi Tarifa" message:@"You must select your destination to continue. Drop a pin in the map to mark your destination." delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil];
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
        
        _pinTo = [GMSMarker markerWithPosition:coordinate];
        _pinTo.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
        _pinTo.title = @"Destino";
        _pinTo.map = _mapView;
        
        [_removePinButton setHidden:NO];
        _mapView.myLocationEnabled = NO;
        
        [self reverseGeocodeLatitude:coordinate.latitude andLongitude:coordinate.longitude inLabel:_toAddressLabel];
        
        NSLog(@"Pin set at: %f,%f", coordinate.latitude, coordinate.longitude);
        
        [_waypoints_ addObject:_pinTo];
        NSString *positionString = [[NSString alloc] initWithFormat:@"%f,%f", _pinTo.position.latitude, _pinTo.position.longitude];
        [_waypointStrings_ addObject:positionString];
        
        if([_waypoints_ count] > 1){
            NSString *sensor = @"false";
            NSArray *parameters = [NSArray arrayWithObjects:sensor, _waypointStrings_,
                                   nil];
            NSArray *keys = [NSArray arrayWithObjects:@"sensor", @"waypoints", nil];
            NSDictionary *query = [NSDictionary dictionaryWithObjects:parameters
                                                              forKeys:keys];
            MDDirectionService *mds=[[MDDirectionService alloc] init];
            SEL selector = @selector(addDirections:);
            [mds setDirectionsQuery:query
                       withSelector:selector
                       withDelegate:self];
        }
    } else {
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Taxi Tarifa" message:NSLocalizedString(@"PIN_NOT_IN_AREA", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ACCEPT", nil) otherButtonTitles:nil, nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Taxi Tarifa" message:@"Solo puedes elegir ubicaciones dentro de Ecuador." delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil];
        [alert show];
    }
}

@end
