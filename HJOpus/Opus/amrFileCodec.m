//
//  amrFileCodec.cpp
//  amrDemoForiOS
//
//  Created by Tang Xiaoping on 9/27/11.
//  Copyright 2011 test. All rights reserved.
//

#include "amrFileCodec.h"

typedef unsigned long long u64;
typedef long long s64;
typedef unsigned int u32;
typedef unsigned short u16;
typedef unsigned char u8;
int amrEncodeMode[] = {4750, 5150, 5900, 6700, 7400, 7950, 10200, 12200}; // amr 编码方式

u16 readUInt16(char* bis) {
    u16 result = 0;
    result += ((u16)(bis[0])) << 8;
    result += (u8)(bis[1]);
    return result;
}

u32 readUint32(char* bis) {
    u32 result = 0;
    result += ((u32) readUInt16(bis)) << 16;
    bis+=2;
    result += readUInt16(bis);
    return result;
}

s64 readSint64(char* bis) {
    s64 result = 0;
    result += ((u64) readUint32(bis)) << 32;
    bis+=4;
    result += readUint32(bis);
    return result;
}



#pragma mark - Decode
//decode

const int myround(const double x)
{
    return((int)(x+0.5));
}

void WriteWAVEHeader(NSMutableData* fpwave, int nFrame)
{
    char tag[10] = "";
    
    // 1. 写RIFF头
    RIFFHEADER riff;
    strcpy(tag, "RIFF");
    memcpy(riff.chRiffID, tag, 4);
    riff.nRiffSize = 4                                     // WAVE
    + sizeof(XCHUNKHEADER)               // fmt
    + sizeof(WAVEFORMATX)           // WAVEFORMATX
    + sizeof(XCHUNKHEADER)               // DATA
    + nFrame*160*sizeof(short);    //
    strcpy(tag, "WAVE");
    memcpy(riff.chRiffFormat, tag, 4);
    //fwrite(&riff, 1, sizeof(RIFFHEADER), fpwave);
    [fpwave appendBytes:&riff length:sizeof(RIFFHEADER)];
    
    // 2. 写FMT块
    XCHUNKHEADER chunk;
    WAVEFORMATX wfx;
    strcpy(tag, "fmt ");
    memcpy(chunk.chChunkID, tag, 4);
    chunk.nChunkSize = sizeof(WAVEFORMATX);
    //fwrite(&chunk, 1, sizeof(XCHUNKHEADER), fpwave);
    [fpwave appendBytes:&chunk length:sizeof(XCHUNKHEADER)];
    memset(&wfx, 0, sizeof(WAVEFORMATX));
    wfx.nFormatTag = 1;
    wfx.nChannels = 1; // 单声道
    wfx.nSamplesPerSec = 8000; // 8khz
    wfx.nAvgBytesPerSec = 16000;
    wfx.nBlockAlign = 2;
    wfx.nBitsPerSample = 16; // 16位
    //fwrite(&wfx, 1, sizeof(WAVEFORMATX), fpwave);
    [fpwave appendBytes:&wfx length:sizeof(WAVEFORMATX)];
    
    // 3. 写data块头
    strcpy(tag, "data");
    memcpy(chunk.chChunkID, tag, 4);
    chunk.nChunkSize = nFrame*160*sizeof(short);
    //fwrite(&chunk, 1, sizeof(XCHUNKHEADER), fpwave);
    [fpwave appendBytes:&chunk length:sizeof(XCHUNKHEADER)];
    
}

int SkipCaffHead(char* buf){
    
    if (!buf) {
        return 0;
    }
    char* oldBuf = buf;
    u32 mFileType = readUint32(buf);
    if (0x63616666!=mFileType) {
        return 0;
    }
    buf+=4;
    
    //    u16 mFileVersion = readUInt16(buf);
    buf+=2;
    //    u16 mFileFlags = readUInt16(buf);
    buf+=2;
    
    //desc free data
    u32 magics[3] = {0x64657363,0x66726565,0x64617461};
    for (int i=0; i<3; ++i) {
        u32 mChunkType = readUint32(buf);buf+=4;
        if (magics[i]!=mChunkType) {
            return 0;
        }
        
        u32 mChunkSize = (u32)readSint64(buf);buf+=8;
        if (mChunkSize<=0) {
            return 0;
        }
        if (i==2) {
            return (int)(buf-oldBuf);
        }
        buf += mChunkSize;
        
    }
    
    return 1;
}
