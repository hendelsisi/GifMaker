//
//  VideoCell.swift
//  LoopVideo
//
//  Created by Minas Kamel on 9/18/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit

class VideoCell: UICollectionViewCell {
    
    static let cellIdentifier = "VideoCell"
    @IBOutlet var videoThumbnailImage: UIImageView!
    @IBOutlet var videoDuration: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    func setup() {
        self.layer.borderWidth = 0.0
        //self.layer.borderColor = UIColor.blue.cgColor
        self.layer.cornerRadius = 5.0
    }
    
}
