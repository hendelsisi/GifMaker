//
//  FileGenerator.swift
//  LoopVideo
//
//  Created by yasmina elsisi on 10/10/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit

class FileGenerator: NSObject {
    static let instance = FileGenerator()
    
     var folderName = ""
     var fileNumber = 0
     var fileName = ""
    
    func getFilePath(type:String) -> URL {
        
        self.setNameBasedType(type: type)
        let documentsPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let folderURL = documentsPath.appendingPathComponent(folderName)
        
        do {
            try FileManager.default.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
        
        } catch let error as NSError {
            print(error.localizedDescription);
        
        }
        let filepath = folderURL.appendingPathComponent(fileName)
        return filepath
       
    }
    
    private func setNameBasedType(type:String)
    {
        if type == "GIF" {
            folderName = "GIF"
            fileNumber = UserDefaults.standard.integer(forKey: Constants.IMAGES_COUNT)
            fileName = ("\(folderName)-\(fileNumber).gif")
            fileNumber+=1
            UserDefaults.standard.set(fileNumber, forKey: Constants.IMAGES_COUNT)
           
        }else{
            folderName = "VIDEOS"
            fileNumber = UserDefaults.standard.integer(forKey: Constants.VIDEOS_COUNT)
            fileName = ("\(folderName)-\(fileNumber).mp4")
            fileNumber+=1
            UserDefaults.standard.set(fileNumber, forKey: Constants.VIDEOS_COUNT)
        }
        
    }
}
