//
//  AudioManager.m
//  TiCommon
//
//  Created by Eason on 15/5/16.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import "AudioManager.h"
#import <UIKit/UIKit.h>

@implementation AudioManager

static AudioManager *sharedAudioManager = nil;

+ (AudioManager *)sharedAudioManager {
     static dispatch_once_t onceToken;
      dispatch_once(&onceToken, ^{
      if(sharedAudioManager == nil)
          sharedAudioManager = [[AudioManager alloc] init];
    });
     return sharedAudioManager;
}

-(void)initCodec
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError* err;
        _encoder = [OKEncoder encoderForASBD:[AudioManager monoCanonicalFormatWithSampleRate:8000] application:kOpusKitApplicationVoIP error:&err];
        _decoder = [OKDecoder decoderForASBD:[AudioManager monoCanonicalFormatWithSampleRate:8000] error:&err];
    });
}


+(AudioStreamBasicDescription)monoCanonicalFormatWithSampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    UInt32 byteSize = 2;
    asbd.mBitsPerChannel   = 8 * byteSize;
    asbd.mBytesPerFrame    = byteSize;
    asbd.mBytesPerPacket   = byteSize;
    asbd.mChannelsPerFrame = 1;
    asbd.mSampleRate       = sampleRate;
    return asbd;
}

- (NSData *)encodeData:(NSData *)data {
    return [_encoder encodeData:data];
}

- (NSData *)decodeData:(NSData *)data {
    return [_decoder decodeData:data];
}

@end
