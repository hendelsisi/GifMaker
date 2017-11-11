//
//  VideoManager.swift
//  LoopVideo
//
//  Created by yasmina elsisi on 10/10/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit

 class VideoManager: LoopControllerManager {
 
   func save (filePath: NSURL)
    {
       CustomAlbumCreator.sharedInstance.saveVideo(filePath: filePath)
    }
}
