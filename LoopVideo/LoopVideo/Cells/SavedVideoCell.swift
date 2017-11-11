//
//  CollectionViewCell.swift
//  LoopVideo
//
//  Created by Shimaa Saeed on 10/13/16.
//  Copyright © 2016 Minas Kamel. All rights reserved.
//

import UIKit

class SavedVideoCell: UICollectionViewCell {

    @IBOutlet weak var video: UIImageView!
    
    @IBOutlet weak var selectButton: UIButton!
    
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
