//
//  VideoGenerator.swift
//  LoopVideo
//
//  Created by yasmina elsisi on 10/10/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit
import AVFoundation

class VideoGenerator: NSObject {
    
    static let instance  = VideoGenerator()
    let videoFolder = "Videos"
    let framesPerSec = 20
    
    func createVideoFromImages (_ images: [UIImage]) -> NSURL
    {
       let filepath = FileGenerator.instance.getFilePath(type: "VIDEOS") as NSURL
        
       guard let videoWriter = try? AVAssetWriter(outputURL: filepath as URL , fileType: AVFileTypeQuickTimeMovie) else {
            fatalError("AVAssetWriter error")
        }
        let videoSettings = [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: 336,
            AVVideoHeightKey: 190
        ] as [String : Any]
        
        let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
        
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: nil)

        videoWriterInput.expectsMediaDataInRealTime = true
        videoWriter.add(videoWriterInput)
        
        //Start a session:
        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: kCMTimeZero)
        
        //convert uiimage to CGImage.
        var buffer:CVPixelBuffer? = nil
        
        var frameCount = 0
        let numberOfSecondsPerFrame = 1
        let frameDuration = framesPerSec * numberOfSecondsPerFrame
        for img in images {
            
            buffer = pixelBufferFromCGImage(img: convertCIImageToCGImage(inputImage: CIImage(image: img)!))
            var append_ok = false
            var j = 0
            while (!append_ok && j < 100){
                if (adaptor.assetWriterInput.isReadyForMoreMediaData)  {
                    let frameTime = CMTimeMake(Int64(frameCount * frameDuration), Int32(framesPerSec))
                    append_ok = adaptor.append(buffer!, withPresentationTime: frameTime)
                    if(!append_ok){
                        let error = videoWriter.error
                        if error != nil {
                            print("Unresolved error \(error)")
                        }
                        
                    }
                }else{
                    print("adaptor not ready")
                    Thread.sleep(forTimeInterval: 0.1)
                }
                j+=1
            }
            if !append_ok{
                print("error appending image \(frameCount) times \(j)\n, with error")
            }
            frameCount+=1
        }
        print("*************************************************")
        
        //Finish the session:
        videoWriterInput.markAsFinished()
        videoWriter.finishWriting {
            print("Write Ended")
        }
        
      return filepath
    }
    
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        if context != nil {
            return context.createCGImage(inputImage, from: inputImage.extent)
        }
        return nil
    }
    
    
    func pixelBufferFromCGImage(img:CGImage)->(CVPixelBuffer){
        
        let size = CGSize(width: 336, height: img.height)
        
        let options = [kCVPixelBufferCGImageCompatibilityKey : NSNumber(booleanLiteral: true),kCVPixelBufferCGBitmapContextCompatibilityKey : NSNumber(booleanLiteral: true)] as [NSObject:NSNumber]
        
        var pxbuffer: CVPixelBuffer? = nil
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault,Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, options as CFDictionary?,&pxbuffer)
        
        if status != kCVReturnSuccess{
            print("Failed to create pixel buffer")
        }
        CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        let pxdata = CVPixelBufferGetBaseAddress(pxbuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pxdata, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: (4) * Int(size.width), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)

        context?.concatenate(CGAffineTransform(rotationAngle: 0))
       
        context?.draw(img, in: CGRect(x:img.width/2, y: 0, width: img.width, height: img.height))

        CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)));
        
        
        return pxbuffer!;

    }
    
    private func addAudioToMovieFile()
    {
        
    }
}
