//
//  LoopControllerManager.swift
//  LoopVideo
//
//  Created by yasmina elsisi on 10/10/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit

class LoopControllerManager: NSObject {
    
    static let instance = LoopControllerManager()
    
    func save(object:NSObject){
        
        if object.isKind(of: UIImage().classForCoder) {
            GIFManager().save(img: object as! UIImage)
            
        }
        else{
            VideoManager().save(filePath: (object as! NSURL))
        }
    }
}
