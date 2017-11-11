//
//  JWGifDecoder.m
//  SaveGifToAlblum
//
//  Created by ZJW on 16/10/12.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "JWGifDecoder.h"
#import <ImageIO/ImageIO.h>

@interface JWGifDecoder ()
{
    CGImageSourceRef _source;
}
@end

@implementation JWGifDecoder

+(instancetype)decoderWithData:(NSData *)data
{
    if ( !data ) return nil;
    
    JWGifDecoder *decoder = [[JWGifDecoder alloc] init];
    [decoder _decoderPrepareWithData:data];
    return decoder;
}

- (void)dealloc
{
    CFRelease(_source);
}

-(void)_decoderPrepareWithData:(NSData *)data
{
    _data = data;
    _source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    _frameCount = CGImageSourceGetCount(_source);
    
    CFDictionaryRef properties = CGImageSourceCopyProperties(_source, NULL);
    CFDictionaryRef gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
    CFTypeRef loop = CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFLoopCount);
    if (loop) CFNumberGetValue(loop, kCFNumberNSIntegerType, &_loopCount);
    CFRelease(properties);
}

-(JWGifFrame *)frameAtIndex:(NSUInteger)index
{
    if ( index >= _frameCount ) return nil;
    
    JWGifFrame *frame = [[JWGifFrame alloc] init];
    
    frame.index = index;
    
    NSTimeInterval duration = 0;
    CFDictionaryRef frameProperties = CGImageSourceCopyPropertiesAtIndex(_source, index, NULL);
    CFDictionaryRef gifFrameProperties = CFDictionaryGetValue(frameProperties, kCGImagePropertyGIFDictionary);
    CFTypeRef delayTime = CFDictionaryGetValue(gifFrameProperties, kCGImagePropertyGIFUnclampedDelayTime);
    if(delayTime) CFNumberGetValue(delayTime, kCFNumberDoubleType, &duration);
    CFRelease(frameProperties);
    frame.duration = duration;

    CGImageRef cgImage = CGImageSourceCreateImageAtIndex(_source, index, NULL);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    frame.image = image;
    CFRelease(cgImage);
    
    return frame;
}

@end
