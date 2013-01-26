//
//  ViewController.m
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


#import "ViewController.h"
//include the libsox headers - check it out for more info
#import "sox.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    audioFile = [NSString stringWithFormat:@"%@/Documents/audio.wav",NSHomeDirectory()];
    NSError *error;
    modifiedAudio = [NSString stringWithFormat:@"%@/Documents/audio_m.wav",NSHomeDirectory()];
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,// kAudioFormatLinearPCM
                              [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                              [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                              [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                              [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                              [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,nil];
    audioRecorder = [[AVAudioRecorder alloc]
                     initWithURL:[NSURL fileURLWithPath:audioFile]
                     settings:settings
                     error:&error];
    audioRecorder.delegate=self;
    
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
        
    } else {
        
        [audioRecorder prepareToRecord];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//simple action to record audio to a file called temp in the phone documents directory.

- (IBAction)recordNewAudioAction:(id)sender {
    UIButton *button= (UIButton*)sender;
  
    if (!audioRecorder.recording)
    {
        [button setTitle:@"Stop Record" forState:UIControlStateNormal];
        
        [audioRecorder record];
    } else {
        [button setTitle:@"Start Record" forState:UIControlStateNormal];
        [audioRecorder stop];        
    }
}

//use the audio file inside the app bundle to manipulate
- (IBAction)useInternalSoundFileAction:(id)sender {
    audioFile =
    [[NSBundle mainBundle] pathForResource: @"lu"
                                    ofType: @"wav"];

}


//this is where the audio manipulation work is being done. change the profile Number to try playing different effects
//check out the docs how to use the different effects.

- (IBAction)applyAudioEffectAction:(id)sender {
    [self transformAudioFileAtPath:audioFile profile:0];
}

/////////////////////////////////



//play the manipulated audio file
- (IBAction)playAudioFile:(id)sender {
    if (!audioRecorder.recording)
    {
        NSError *error;
        if (effectEnabled) {
            audioPlayer = [[AVAudioPlayer alloc]
                           initWithContentsOfURL:[NSURL fileURLWithPath:modifiedAudio]
                           error:&error];
        } else {
        audioPlayer = [[AVAudioPlayer alloc]
                       initWithContentsOfURL:[NSURL fileURLWithPath:audioFile]
                       error:&error];
        }
        [audioPlayer prepareToPlay];
        [audioPlayer play];
    }
}


//this function is where the audio manipulation is being done.
//call it with different profile to apply different audio effects.
//path is the original file location
//the new audio file is written to modifiedAudio location
// check out http://uberblo.gs/2011/04/iosiphoneos-equalizer-with-libsox-doing-effects
// for original post

- (NSString *)transformAudioFileAtPath:(NSString *)path profile:(int)tprofile {
	static sox_format_t *in, *out; /* input and output files */
	sox_effects_chain_t * chain;
	sox_effect_t * e;
	char *args[10];
	
    //    if ([[NSFileManager alloc] fileExistsAtPath:target])
    //		return target;
	
	/* All libSoX applications must start by initialising the SoX library */
	assert(sox_init() == SOX_SUCCESS);
    
	/* Open the input file (with default parameters) */
	assert(in = sox_open_read([path UTF8String], NULL, NULL, NULL));
	
	/* Open the output file; we must specify the output signal characteristics.
	 * Since we are using only simple effects, they are the same as the input
	 * file characteristics */
	assert(out = sox_open_write([modifiedAudio UTF8String], &in->signal, NULL, NULL, NULL, NULL));
	
	/* Create an effects chain; some effects need to know about the input
	 * or output file encoding so we provide that information here */
	chain = sox_create_effects_chain(&in->encoding, &out->encoding);
	
	/* The first effect in the effect chain must be something that can source
	 * samples; in this case, we use the built-in handler that inputs
	 * data from an audio file */
	e = sox_create_effect(sox_find_effect("input"));
	args[0] = (char *)in, assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
	/* This becomes the first `effect' in the chain */
	assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
	if (tprofile == 0) {
		//small hall effect
		e = sox_create_effect(sox_find_effect("reverb"));
		args[0] = "60", assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
		assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
		
	}
    
    if (tprofile == 1) {
		//small hall effect
		e = sox_create_effect(sox_find_effect("reverse"));
        //		args[0] = "90", assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
		assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
		
		//e = sox_create_effect(sox_find_effect("gain"));
		//args[0] = "-10", assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
		//assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
	}
    
    if (tprofile == 2) {

		e = sox_create_effect(sox_find_effect("highpass"));
		args[0] = "2000", assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
		assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
		
		e = sox_create_effect(sox_find_effect("gain"));
		args[0] = "-10", assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
		assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
	}
    
	
	/* Create the `vol' effect, and initialise it with the desired parameters: */
	e = sox_create_effect(sox_find_effect("vol"));
	args[0] = "3dB", assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
	/* Add the effect to the end of the effects processing chain: */
	assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
	
	/* Create the `flanger' effect, and initialise it with default parameters: */
	e = sox_create_effect(sox_find_effect("flanger"));
	assert(sox_effect_options(e, 0, NULL) == SOX_SUCCESS);
	/* Add the effect to the end of the effects processing chain: */
	assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
    
	
	/* The last effect in the effect chain must be something that only consumes
	 * samples; in this case, we use the built-in handler that outputs
	 * data to an audio file */
	e = sox_create_effect(sox_find_effect("output"));
	args[0] = (char *)out, assert(sox_effect_options(e, 1, args) == SOX_SUCCESS);
	assert(sox_add_effect(chain, e, &in->signal, &in->signal) == SOX_SUCCESS);
	
	/* Flow samples through the effects processing chain until EOF is reached */
	sox_flow_effects(chain, NULL, NULL);
	
	/* All done; tidy up: */
	sox_delete_effects_chain(chain);
	sox_close(out);
	sox_close(in);
	sox_quit();
	
    effectEnabled=YES;
	return soundFilePath;
    
    
    
}


//you might want to do something here
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"Done");    
}

@end
