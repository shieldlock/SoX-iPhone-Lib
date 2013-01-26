//
//  ViewController.h
//  AudioEffects
//
//  Created by Andy Rash itunes on 1/12/13.
//  You are free to modify and use this sample project as you want.
//  for libsox license usage and modifications checkout the web site at sox.sourceforge.net
//
//  Copyright (c) 2013 ShieldLock. All rights reserved.
//
//  Did this sampe helped you ? show your support by  checking out our cool products for developers Cloud Guardian and Cloud Care.
//  http://www.shield-lock.com



#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <AVAudioRecorderDelegate>
{
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    NSString *audioFile,*newAudioFile,*soundFilePath,*modifiedAudio;
    BOOL effectEnabled;
}
- (IBAction)recordNewAudioAction:(id)sender;
- (IBAction)useInternalSoundFileAction:(id)sender;
- (IBAction)applyAudioEffectAction:(id)sender;
- (IBAction)playAudioFile:(id)sender;

@end
