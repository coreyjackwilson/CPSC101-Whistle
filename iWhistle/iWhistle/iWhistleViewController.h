//
//  iWhistleViewController.h
//  iWhistle
//
//  Created by Corey Wilson and Shauna McGuire on 11/24/2013.
//  Copyright (c) 2013 Corey Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MessageUI/MessageUI.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <CoreLocation/CoreLocation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface iWhistleViewController : UIViewController
<CLLocationManagerDelegate> {
    UIButton *onButton;
    UIButton *offButton;
    UIImageView *onView;
    UIImageView *offView;
    AVAudioPlayer *player;
    __weak IBOutlet UILabel *uiLabel;
    __weak IBOutlet UILabel *longitudeLabel;
    __weak IBOutlet UILabel *latitudeLabel;
    __weak IBOutlet UILabel *addressLabel;
}

@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic,strong) IBOutlet UIButton *onButton;
@property (nonatomic,strong) IBOutlet UIButton *offButton;
@property (nonatomic,strong) IBOutlet UIImageView *onView;
@property (nonatomic,strong) IBOutlet UIImageView *offView;

-(IBAction)torchOn:(id)sender;
-(IBAction)torchOff:(id)sender;
-(IBAction)boom;
-(IBAction)noBoom;
-(IBAction)sendSMS:(id)sender;
-(IBAction)clickShare:(id)sender;
-(IBAction)postTweet:(id)sender;
-(IBAction)getCurrentLocation:(id)sender;


@end
