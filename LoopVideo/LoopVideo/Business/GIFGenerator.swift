//
//  GIFGenerator.swift
//  LoopVideo
//
//  Created by yasmina elsisi on 9/27/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit

class GIFGenerator: NSObject {
    let kFrameCount = 16
    
    static let instance  = GIFGenerator()
    let gifImgFolder = "Animated"
  
    func createGIFImg (_ images: [UIImage]) -> String
    {
        let filepath = FileGenerator.instance.getFilePath(type: "GIF") as URL
        
        let dest = CGImageDestinationCreateWithURL(filepath as CFURL, kUTTypeGIF, images.count, nil)
      
        for img in images {
            CGImageDestinationAddImage(dest!, img.cgImage!, nil)
        }
        if !CGImageDestinationFinalize(dest!){
            print("failed to finalize image destination")
            return ""
        }else{
            print("Sucsess url =  \(filepath)")
            return filepath.relativePath
        }
    }
    /////////////////////////////////////
    func createGIFImgurl (_ images: [UIImage]) -> URL
    {
        let filepath = FileGenerator.instance.getFilePath(type: "GIF") as URL
        
        let dest = CGImageDestinationCreateWithURL(filepath as CFURL, kUTTypeGIF, images.count, nil)
        
        for img in images {
            CGImageDestinationAddImage(dest!, img.cgImage!, nil)
        }
//        if !CGImageDestinationFinalize(dest!){
//            print("failed to finalize image destination")
//            return nil
//        }else{
//            print("Sucsess url =  \(filepath)")
//            
//        }
        return filepath
    }
    
    

}
