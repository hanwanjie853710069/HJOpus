//
//  AudioManager.h
//  TiCommon
//
//  Created by Eason on 15/5/16.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "OKEncoder.h"
#import "OKDecoder.h"

@interface AudioManager : NSObject {
    OKEncoder* _encoder;
    OKDecoder* _decoder;
}

+ (AudioManager *)sharedAudioManager;

-(void)initCodec;

- (NSData *)encodeData:(NSData *)data;

- (NSData *)decodeData:(NSData *)data;

@end
