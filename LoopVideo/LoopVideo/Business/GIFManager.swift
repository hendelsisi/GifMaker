//
//  GIFManager.swift
//  LoopVideo
//
//  Created by yasmina elsisi on 10/10/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit

class GIFManager: LoopControllerManager {
    
    
    func save (img: UIImage)
    {
        CustomAlbumCreator.sharedInstance.saveImage(image: img)
    }

}
