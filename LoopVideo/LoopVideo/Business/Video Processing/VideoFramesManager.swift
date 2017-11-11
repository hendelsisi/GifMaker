//
//  VideoFramesManager.swift
//  LoopVideo
//
//  Created by Minas Kamel on 9/20/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import Foundation
import AVFoundation

protocol VideoFramesManagerDelegate {
    func videoFramesAreReady(_ images : [UIImage])
    func videoImagesAreReady(_ images : [UIImage])
}

class VideoFramesManager {
    var videoDuration = 0.0
    static let instance = VideoFramesManager()
    var delegate : VideoFramesManagerDelegate?
    
    static let requiredFramesForOneSecond : Int = 1
    let defaultFrameRate : Float = 60.0
    var asset : AVURLAsset!
    var numOfImgs = 0

    func extractVideoFrames(_ asset : AVURLAsset) {
        self.asset = asset
            self.delegate?.videoFramesAreReady(self.generateFramesPhotos())
    }
    
    fileprivate func generateFramesPhotos() -> [UIImage] {
        var images = [UIImage]()
        
        let videoDurationInSeconds = Int(asset.duration.value) / Int(asset.duration.timescale)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter = kCMTimeZero;
        assetImgGenerate.requestedTimeToleranceBefore = kCMTimeZero;
        assetImgGenerate.maximumSize = CGSize(width: 65, height: 40);

        var currentSecond = 0.0
        
        let startTime = Date()
        
        for _ in 0..<videoDurationInSeconds*VideoFramesManager.requiredFramesForOneSecond {
            do {
                let img : CGImage = try assetImgGenerate.copyCGImage(at: CMTimeMakeWithSeconds(currentSecond, 600), actualTime: nil)
                images.append(UIImage(cgImage: img))
                currentSecond += 1/Double(VideoFramesManager.requiredFramesForOneSecond)
            } catch {
                
            }
 
        }
        
        print("Time: \(startTime.timeIntervalSinceNow)")
        
        return images
    }
    
    
  func generateFramesPhotosFromSpecificTime (_ startingTime: Double) -> [UIImage] {
    
        let requiredImgInspecificTime = prepareImagesWhenSpecificTimeSellected(startingTime)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter = kCMTimeZero;
        assetImgGenerate.requestedTimeToleranceBefore = kCMTimeZero;
       // assetImgGenerate.maximumSize = CGSize(width: 350, height: 291);
    
        var images = [UIImage]()
    
        self.numOfImgs = requiredImgInspecificTime.count
    
        assetImgGenerate.generateCGImagesAsynchronously(forTimes: requiredImgInspecificTime) { _, image, _, res, error in
        if (res == .succeeded) {
            // do your success stuff in here
            images.append(UIImage(cgImage: image!))
            
            if images.count == self.numOfImgs {
                self.delegate?.videoImagesAreReady(images)
            }
            
        }
    }
        return images
   }
    
    fileprivate func prepareImagesWhenSpecificTimeSellected(_ startingTime: Double) -> [NSValue]
    {
       var requiredImgInspecificTime = [NSValue]()
       var imgsBeforeSelectedTime = [NSValue]()
       var imgsAfterSelectedTime = [NSValue]()
        
        var currentSelectedValue = startingTime
        
        
        
        if self.videoDuration < 10.0 {
            for _ in 0  ..< 3  {
                
                currentSelectedValue = currentSelectedValue - 0.1
                imgsBeforeSelectedTime.append(currentSelectedValue as NSValue)
            }
        }
        else{
            for _ in 0  ..< 10  {
                
                currentSelectedValue = currentSelectedValue - 0.1
                imgsBeforeSelectedTime.append(currentSelectedValue as NSValue)
            }
        }
        
        requiredImgInspecificTime.append(contentsOf: imgsBeforeSelectedTime.reversed())
        requiredImgInspecificTime.append(startingTime as NSValue)
        
        currentSelectedValue = startingTime
        
         if self.videoDuration < 10.0 {
            for  _ in 0  ..< 3{
                currentSelectedValue = currentSelectedValue + 0.1
                imgsAfterSelectedTime.append(currentSelectedValue as NSValue)
            }
        }
        else{
            for  _ in 0  ..< 10{
                currentSelectedValue = currentSelectedValue + 0.1
                imgsAfterSelectedTime.append(currentSelectedValue as NSValue)
            }
        
        }
        
        requiredImgInspecificTime.append(contentsOf: imgsAfterSelectedTime)
        requiredImgInspecificTime.removeLast()
        requiredImgInspecificTime.append(contentsOf: imgsAfterSelectedTime.reversed())
        requiredImgInspecificTime.append(startingTime as NSValue)
        
        self.numOfImgs = requiredImgInspecificTime.count
       return requiredImgInspecificTime
    
    }
}
