//
//  OpusDecoder.m
//  OpusKit
//
//  Created by Christopher Ballinger on 2/17/14.
//
//

#import "OKDecoder.h"
#import "opus.h"
#import <AVFoundation/AVFoundation.h>
static const int kNumberOfSamplesPerChannel = 160;

@interface OKDecoder()
@property (nonatomic) OpusDecoder *decoder;
@property (nonatomic) opus_int16 *outputBuffer;
@property (nonatomic) NSUInteger decoderBufferLength;
@end

@implementation OKDecoder

- (void) dealloc {
    if (_decoder) {
        opus_decoder_destroy(_decoder);
    }
    if (_outputBuffer) {
        free(_outputBuffer);
    }
}

- (id) initWithSampleRate:(OpusKitSampleRate)sampleRate numberOfChannels:(OpusKitChannels)channels {
    if (self = [super initWithSampleRate:sampleRate numberOfChannels:channels]) {
        _forwardErrorCorrection = NO;
        _decoderBufferLength = kNumberOfSamplesPerChannel*self.numberOfChannels*sizeof(opus_int16);
        self.outputBuffer = malloc(_decoderBufferLength);
        memset(self.outputBuffer, 0, _decoderBufferLength);
    }
    return self;
}


- (BOOL) setupDecoderWithError:(NSError *__autoreleasing *)error {
    if (self.decoder) {
        return YES;
    }
    int opusError = OPUS_OK;
    self.decoder = opus_decoder_create(self.sampleRate, self.numberOfChannels, &opusError);
    opus_decoder_ctl(self.decoder, OPUS_SET_BANDWIDTH(OPUS_BANDWIDTH_SUPERWIDEBAND));
    if (opusError != OPUS_OK) {
        return NO;
    }
    
    return YES;
}

+ (OKDecoder*) decoderForASBD:(AudioStreamBasicDescription)absd error:(NSError *__autoreleasing *)error {
    OKDecoder *decoder = [[OKDecoder alloc] initWithSampleRate:absd.mSampleRate numberOfChannels:absd.mChannelsPerFrame];
    BOOL success = [decoder setupDecoderWithError:error];
    if (success) {
        return decoder;
    }
    return nil;
}

void WriteWAVEHeader(NSMutableData* fpwave, int nFrame);
- (NSData*) decodeData:(NSData *)packetData
{
    unsigned char* pointer = (unsigned char*)packetData.bytes;
    int32_t decodedSamples = 0;
    int32_t decodeSize = 0;
//    int16_t size = 0;
//    [packetData getBytes:&size length:1];
    NSMutableData* ret = [[NSMutableData alloc]init];
    int i = 0;
    while(decodeSize < packetData.length)
    {
        int returnValue = opus_decode(_decoder, pointer, 32, _outputBuffer, kNumberOfSamplesPerChannel, _forwardErrorCorrection);
        if (returnValue < 0) {
            return ret;
        }
        pointer+= 32;
        decodeSize += 32;
        decodedSamples = returnValue;
        NSUInteger length = decodedSamples * sizeof(opus_int16) * self.numberOfChannels;
        [ret appendBytes:_outputBuffer length:length];
        ++i;
    }
    NSMutableData* finalData = [NSMutableData data];
    WriteWAVEHeader(finalData, i);
    [finalData appendData:ret];
    return finalData;
}

@end
