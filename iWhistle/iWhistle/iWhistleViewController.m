//
//  iWhistleViewController.m
//  iWhistle
//
//  Created by Corey Wilson and Shauna McGuire on 11/24/2013.
//  Copyright (c) 2013 Corey Wilson. All rights reserved.
//

#import "iWhistleViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface iWhistleViewController ()
@property (nonatomic, strong) ACAccountStore *accountStore;
@end

@implementation iWhistleViewController {

    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

@synthesize offButton, onView, onButton, offView;
@synthesize player;


-(IBAction) boom; {
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingString:@"/whistle.mp3"];
    NSLog(@"Path to play: %@", resourcePath);
    NSError* err;
    
    //Initialize our player pointing to the path to our resource
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:
              [NSURL fileURLWithPath:resourcePath] error:&err];
    
    if( err ){
        //bail!
        NSLog(@"Failed with reason: %@", [err localizedDescription]);
    }
    else{
        //set our delegate and begin playback
        player.delegate = self;
        [player play];
        player.numberOfLoops = -1;
        player.currentTime = 0;
        player.volume = 1.0;
    }
    
}

-(IBAction)noBoom; {
    [player stop];
}


-(IBAction)torchOn:(id)sender {
    onButton.hidden = YES;
    offButton.hidden = NO;
    
    onView.hidden = NO;
    offView.hidden = YES;
    
    AVCaptureDevice *flashLight = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
    if ([flashLight isTorchAvailable] && [flashLight isTorchModeSupported: AVCaptureTorchModeOn])
    {
        BOOL success = [flashLight lockForConfiguration:nil];
        if (success)
        {
            [flashLight setTorchMode:AVCaptureTorchModeOn];
            [flashLight unlockForConfiguration];
        }
    }
}

-(IBAction)torchOff:(id)sender {
    onButton.hidden = NO;
    offButton.hidden = YES;
    
    
    onView.hidden = YES;
    offView.hidden = NO;
    
    AVCaptureDevice *flashLight = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
    if ([flashLight isTorchAvailable] && [flashLight isTorchModeSupported: AVCaptureTorchModeOn])
    {
        BOOL success = [flashLight lockForConfiguration:nil];
        if (success)
        {
            [flashLight setTorchMode:AVCaptureTorchModeOff];
            [flashLight unlockForConfiguration];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
	// Do any additional setup after loading the view, typically from a nib.
    FBLoginView* loginView = [[FBLoginView alloc] init];
    loginView.delegate = self;
    loginView.frame = CGRectOffset(loginView.frame, 50, 50);
    [self.view addSubview:loginView];
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(IBAction) sendSMS:(id) sender
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        CLLocation *location=[self findCurrentLocation];
        CLLocationCoordinate2D coordinae=[location coordinate];
        controller.body =[[NSString alloc] initWithFormat:@" This is an iWhistle Alert!, locate the send at latitude:%f longitude:%f ! They need your help!",coordinae.latitude,coordinae.longitude]; ;
        controller.recipients = [NSArray arrayWithObjects:@"911", nil];
        [self presentModalViewController:controller animated:YES];
    }
}
-(CLLocation*)findCurrentLocation
{
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    if ([locationManager locationServicesEnabled])
    {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        [locationManager startUpdatingLocation];
    }
    
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    return location;
    
}

-(IBAction)clickShare:(id)sender {
     [[FBSession activeSession]
         reauthorizeWithPublishPermissions:@[@"publish_actions"]
         defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error) {
             CLLocation *location=[self findCurrentLocation];
             CLLocationCoordinate2D coordinae=[location coordinate];
             [FBRequestConnection startForPostStatusUpdate: [[NSString alloc] initWithFormat:@" @iWhistle alert!, get to the location latitude:%f longitude:%f ! Someone needs your help!",coordinae.latitude,coordinae.longitude] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                 if (error) {
                     NSLog(@"error!");
                 } else {
                     NSLog(@"success!");
                 }
             }];
         }];
    }
-(IBAction)postTweet:(id)sender {
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:
                                  ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil
                                  completion:^(BOOL granted, NSError *error)
    {
        if (granted == YES)
        {
            NSArray *arrayOfAccounts = [account
                                        accountsWithAccountType:accountType];
            
            if ([arrayOfAccounts count] > 0)
            {
                ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                CLLocation *location=[self findCurrentLocation];
                CLLocationCoordinate2D coordinae=[location coordinate];
                NSDictionary *message = [[NSString alloc] initWithFormat:@" iWhistle Alert!, call the senders number with latitude:%f longitude:%f ! Someone needs your help!",coordinae.latitude,coordinae.longitude];
                
                NSURL *requestURL = [NSURL
                                     URLWithString:@"http://api.twitter.com/1/statuses/update.json"];
                
                SLRequest *postRequest = [SLRequest
                                          requestForServiceType:SLServiceTypeTwitter
                                          requestMethod:SLRequestMethodPOST
                                          URL:requestURL parameters:message];
                
                postRequest.account = twitterAccount;
                
                [postRequest performRequestWithHandler:^(NSData *responseData,
                                                         NSHTTPURLResponse *urlResponse, NSError *error)
                 {
                     NSLog(@"Twitter HTTP response: %i", [urlResponse 
                                                          statusCode]);
                 }];
            }
        }
    }];}
-(IBAction)getCurrentLocation:(id)sender {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        longitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        latitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }

    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            addressLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                 placemark.subThoroughfare, placemark.thoroughfare,
                                 placemark.postalCode, placemark.locality,
                                 placemark.administrativeArea,
                                 placemark.country];
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
}
@end