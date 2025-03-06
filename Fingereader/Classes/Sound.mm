//
//  Sound.m
//  Fingereader
//
//  Created by Ali Mahouk on 8/6/13.
//  Copyright (c) 2013 Ali Mahouk. All rights reserved.
//

#import "Sound.h"

@implementation Sound

+ (void)soundEffect:(int)soundNumber
{
	
    NSString *effect = @"";
    NSString *type = @"";
	
	switch ( soundNumber )
    {
        case 0:
			effect = @"error_01";
			type = @"wav";
			break;
		default:
			break;
	}
	
    SystemSoundID soundID;
	
    NSString *path = [[NSBundle mainBundle] pathForResource:effect ofType:type];
    NSURL *url = [NSURL fileURLWithPath:path];
	
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

@end
